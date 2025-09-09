class API::Internal::ApplicationController < ApplicationController
  skip_forgery_protection if Rails.env.development?

  rescue_from CanCan::AccessDenied do
    render json nothing: true, status: :not_found
  end

  def authenticate
    session_record = Session.find_by_id(cookies.signed[:session_token])
    if session_record.present?
      Current.session = session_record
      # TODO: PRO
      # if session_record.user.verified?
      #   Current.session = session_record
      # else
      #   render json: { error: "Unverified email" }, status: :precondition_required
      # end
      return
    end
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end
end
