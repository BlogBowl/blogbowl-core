class API::Public::PostmarkController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :verify_api_key

  def on_postmark_event
    record_type = params["RecordType"]

    if record_type.nil?
      notify_message("[Postmark] Webhook triggered - Record type does not exist", extra_context: params.as_json)
      render json: {}, status: :bad_request
      return
    end

    permitted_params = params.permit!
    ProcessPostmarkEventJob.perform_later(permitted_params)
  end

  private

  def verify_api_key
    expected_api_key = ENV.fetch('POSTMARK_X_API_KEY', Rails.application.credentials[Rails.env.to_sym][:postmark][:x_api_key])
    provided_api_key = request.headers['X-Api-Key']

    # Check if the API key matches
    unless provided_api_key && provided_api_key == expected_api_key
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

end
