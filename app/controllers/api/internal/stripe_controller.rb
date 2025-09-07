class API::Internal::StripeController < ActionController::Base
  skip_forgery_protection

  ENDPOINT_SECRET = Rails.env.development? ?
                      'whsec_4d5b2cfafb136cb0301cea58cd81281774165cd3dfeac60ed837eef5cb8a4e41'
                      : Rails.application.credentials[Rails.env.to_sym][:stripe][:webhook_secret]

  def webhook
    payload = request.body.read

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      render json: { message: e.message }, status: 400 and return
      return
    end

    if ENDPOINT_SECRET
      # Retrieve the event by verifying the signature using the raw body and secret.
      signature = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        event = Stripe::Webhook.construct_event(
          payload, signature, ENDPOINT_SECRET
        )
      rescue Stripe::SignatureVerificationError => e
        render json: { message: e.message }, status: 400 and return
      end
    else
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    end

    # Handle the event
    case event.type
    when 'customer.subscription.created'
      StripeService::handle_subscription_change(event.data.object)
    when 'customer.subscription.updated'
      StripeService::handle_subscription_change(event.data.object)
    when 'customer.subscription.deleted'
      StripeService::handle_subscription_change(event.data.object)
    when 'invoice.payment_failed'
      StripeService::handle_failed_invoice(event.data.object)
    else
      # nothing
    end

    render json: { message: 'success' }
  end
end
