class SessionsController < ApplicationController
  layout "authentication"

  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    redirect_to after_authentication_path if authenticated?
  end

  def create
    user = User.authenticate_by(params.permit(:email, :password))
    if user.present?
      start_new_session_for user
      redirect_to after_authentication_path
    else
      redirect_to new_session_path, alert: "That email or password is incorrect"
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end
end
