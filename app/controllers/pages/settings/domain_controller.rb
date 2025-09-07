class Pages::Settings::DomainController < Pages::Settings::ApplicationController
  before_action :set_domain_prefix
  before_action :set_toggles

  def edit
  end

  def update
    # TODO: PRO
    # if @workspace.free? && params[:page_setting][:own_domain] == '1' && Rails.env.production?
    #   flash.now[:alert] = "To set custom domain, please upgrade plan!"
    #   render :edit, status: :unprocessable_entity and return
    # end

    if @page_settings.update(page_setting_params)
      flash[:notice] = "Page settings were updated successfully."
      redirect_to edit_pages_settings_domain_path
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    result = params.require(:page_setting).permit(:own_domain, :subfolder_enabled, page_attributes: [:domain, :base_domain])
    result[:own_domain] = result[:own_domain] == "1"
    result[:page_attributes][:domain] = result[:page_attributes][:domain] + @domain_prefix unless result[:own_domain]
    result.delete(:own_domain)
    result
  end

  def set_domain_prefix
    @domain_prefix = '.blogbowl.app' if Rails.env.production?
    @domain_prefix = '.blogbowl.app' if Rails.env.development?
    @domain_prefix = '.example.com' if Rails.env.test?
  end

  def set_toggles
    @has_own_domain = !@page.domain.ends_with?(@domain_prefix)
    @can_set_own_domain = true

    @page.domain = @page.domain.gsub(@domain_prefix, '') if @page.domain.present? && !@has_own_domain
  end
end
