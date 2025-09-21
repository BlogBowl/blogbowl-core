module API::Internal::ApplicationControllerConcern
  extend ActiveSupport::Concern

  included do
    skip_forgery_protection if Rails.env.development?

    rescue_from CanCan::AccessDenied do
      render json nothing: true, status: :not_found
    end
  end

  def authenticate
    session_record = Session.find_by_id(cookies.signed[:session_token])
    if session_record.present?
      Current.session = session_record
      return
    end
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end

end