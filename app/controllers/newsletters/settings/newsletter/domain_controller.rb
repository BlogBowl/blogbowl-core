class Newsletters::Settings::Newsletter::DomainController < Newsletters::Settings::ApplicationController
  # TODO: PRO
  # DOMAIN_PREFIX = 'mail.blogbowl.io'.freeze

  # TODO: PRO
  # def edit
  #   is_custom_mail = Rails.application.config.x.application_tier == :open_source || @newsletter_settings.domain.nil? || !@newsletter_settings.domain.ends_with?(DOMAIN_PREFIX)
  #   @has_own_domain = @newsletter_settings.domain.nil? || is_custom_mail
  #   @domain_details = @newsletter_settings.postmark_domain_id.nil? || !is_custom_mail ? nil : get_domain_details(@newsletter_settings.postmark_domain_id)
  # end

  def edit
    is_custom_mail = true
    @has_own_domain = @newsletter_settings.domain.nil? || is_custom_mail
    @domain_details = @newsletter_settings.postmark_domain_id.nil? || !is_custom_mail ? nil : get_domain_details(@newsletter_settings.postmark_domain_id)
  end

  def update
    sender_attributes = newsletter_setting_params.except(:domain).compact

    unless @newsletter_settings.update(sender_attributes)
      flash.now[:alert] = @newsletter_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity and return
    end

    if @newsletter_settings.domain.nil?
      create_new_domain(newsletter_setting_params[:domain])
      # TODO: PRO
      # if newsletter_setting_params[:domain] == DOMAIN_PREFIX
      #   flash[:notice] = "Domain was successfully added"
      # else
      #   flash[:notice] = "Domain was successfully added. Now you need to verify it."
      # end
      flash[:notice] = "Domain was successfully added. Now you need to verify it."
    else
      if @newsletter_settings.domain == newsletter_setting_params[:domain]
        flash[:notice] = "Newsletter settings were updated successfully."
      else
        unless @newsletter_settings.postmark_domain_id.nil?
          delete_domain(@newsletter_settings.postmark_domain_id)
          @newsletter_settings.update(postmark_domain_id: nil)
        end
        create_new_domain(newsletter_setting_params[:domain])
      end
    end

    redirect_to edit_newsletters_settings_newsletter_domain_path
  rescue => e
    Rails.logger.error "Failed to add domain: #{e.message}"
    # TODO: PRO
    # Sentry.capture_exception(e, extra: { newsletter: @newsletter.id })
    flash[:alert] = "There was an error updating domain. If the problem persists, please, contact support."
    render :edit, status: :unprocessable_entity
  end

  def verify_dkim
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)
    response = client.verify_domain_dkim(@newsletter_settings.postmark_domain_id)
    if response[:dkim_verified]
      flash[:notice] = "DKIM was successfully verified"
    else
      flash[:alert] = "DKIM is not verified yet"
    end
    redirect_to edit_newsletters_settings_newsletter_domain_path
  rescue => e
    Rails.logger.error "Failed to verify DKIM domain: #{e.message}"
    # TODO: PRO
    # Sentry.capture_exception(e, extra: { newsletter: @newsletter.id })
    flash[:alert] = "DKIM is not verified yet"
    redirect_to edit_newsletters_settings_newsletter_domain_path
  end

  def verify_return_path
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)
    response = client.verify_domain_return_path(@newsletter_settings.postmark_domain_id)
    if response[:return_path_domain_verified]
      flash[:notice] = "Return-Path was successfully verified"
    else
      flash[:alert] = "Return-Path is not verified yet"
    end
    redirect_to edit_newsletters_settings_newsletter_domain_path
  rescue => e
    Rails.logger.error "Failed to verify Return-Path: #{e.message}"
    # TODO: PRO
    # Sentry.capture_exception(e, extra: { newsletter: @newsletter.id })
    flash[:alert] = "Return-Path is not verified yet"
    redirect_to edit_newsletters_settings_newsletter_domain_path
  end

  def newsletter_setting_params
    params.require(:newsletter_setting).permit(:domain, :sender_name, :sender, :reply_to_email, :footer, :logo, :remove_logo)
  end

  private

  def create_new_domain(domain)
    # TODO: PRO
    # if newsletter_setting_params[:domain] == DOMAIN_PREFIX
    #   @newsletter_settings.update(domain: DOMAIN_PREFIX)
    # else
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)
    created_domain_response = client.create_domain({ name: domain })
    @newsletter_settings.update(domain: created_domain_response[:name], postmark_domain_id: created_domain_response[:id])
  end

  def delete_domain(postmark_domain_id)
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)

    client.delete_domain(postmark_domain_id)
  end

  def get_domain_details(postmark_domain_id)
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials[Rails.env.to_sym][:postmark][:account_token])
    client = Postmark::AccountApiClient.new(account_token)

    client.get_domain(postmark_domain_id)
  end
end
