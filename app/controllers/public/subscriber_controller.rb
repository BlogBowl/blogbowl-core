class Public::SubscriberController < Public::ApplicationController
  before_action :set_newsletter

  include PublicHelper

  RATE_LIMIT_WINDOW = 1.hour
  MAX_ATTEMPTS_PER_IP = 3

  def create
    return block_ip if ip_rate_limited?

    Rails.logger.warn({
                        message: "Subscription user agent",
                        userAgent: request.user_agent.to_s
                      }.to_json)

    validation_result = Truemail.validate(params[:subscriber][:email])

    if validation_result.result.success == false || params[:subscriber][:comment].present?
      flash[:alert] = 'Subscription failed'
      render turbo_stream: turbo_stream.replace("subscription_message", partial: "shared/verify_subscribe_error", locals: { message: 'Subscription failed!' })
      return
    end

    existing_subscriber = Subscriber.find_by(email: subscriber_params[:email], newsletter: @newsletter)

    if existing_subscriber.present?
      # suppression_reason https://postmarkapp.com/developer/webhooks/subscription-change-webhook#subscription-change-webhook-data
      if existing_subscriber.status == 'pending' or (existing_subscriber.status == 'suppressed' and existing_subscriber.suppression_reason == 'ManualSuppression')
        send_verification_email(existing_subscriber)
      end
      render turbo_stream: turbo_stream.replace("subscription_message", partial: "shared/verify_subscribe_modal")
    else
      @subscriber = Subscriber.new(subscriber_params)
      @subscriber.newsletter = @newsletter
      @subscriber.status = 'pending'
      @subscriber.page = @page

      if @subscriber.save
        send_verification_email(@subscriber)
        render turbo_stream: turbo_stream.replace("subscription_message", partial: "shared/verify_subscribe_modal")
      else
        flash[:alert] = 'Subscription failed'
        render turbo_stream: turbo_stream.replace("subscription_message", partial: "shared/verify_subscribe_error", locals: { message: 'Subscription failed!' })
      end
    end
  end

  def verify
    @subscriber = Subscriber.find_by(verification_token: params[:token])

    if @subscriber
      @subscriber.verify
      flash[:notice] = 'Your subscription is now verified!'
    else
      flash[:alert] = 'Invalid verification link.'
    end

    redirect_to root_path
  end

  private

  def set_newsletter
    @newsletter = @page_settings.newsletter
  end

  def send_verification_email(subscriber)
    flash[:notice] = 'Please check your email to verify your subscription.'

    if !subscriber.verification_token.nil? and subscriber.verification_email_sent_at > 1.hour.ago
      return
    end

    verification_token = SecureRandom.urlsafe_base64
    subscriber.update(verification_token: verification_token, verification_email_sent_at: Time.current, ip_address: request.remote_ip)
    verification_url = get_full_base_url(dynamic_prefix("/subscribe/verify/#{subscriber.verification_token}"))
    SubscriberMailer.verification_email(subscriber, verification_url).deliver_later
  end

  def ip_rate_limited?
    ip_address = request.remote_ip
    recent_attempts = Subscriber.where(
      created_at: RATE_LIMIT_WINDOW.ago..Time.current,
      ip_address: ip_address,
      newsletter_id: @newsletter.id
    ).count

    recent_attempts >= MAX_ATTEMPTS_PER_IP
  end

  def block_ip
    # Log the IP
    # TODO: PRO
    # Sentry.capture_message("[SUBSCRIBE] IP blocked: #{request.remote_ip}")

    # Optionally add IP to a block list or temporary ban
    flash[:alert] = 'Too many subscription attempts. Please try again later.'
    render turbo_stream: turbo_stream.replace("subscription_message", partial: "shared/verify_subscribe_error", locals: { message: 'Too many requests!' })
  end

  def subscriber_params
    params.require(:subscriber).permit(:email)
  end

end
