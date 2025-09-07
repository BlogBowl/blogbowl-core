class RegistrationsController < ApplicationController
  layout "authentication"

  skip_before_action :authenticate

  def new
    @user = User.new
    if params[:invitation_token].present?
      data = InvitationService.instance.verify_invitation(params[:invitation_token])
      return if data.nil?
      @user.email = data[:email]
    end
  end

  def create
    @user = User.new(user_params)
    @user.verified = has_valid_invitation_token?

    if @user.save
      session_record = @user.sessions.create!
      set_session_cookie(session_record)

      if has_valid_invitation_token?
        redirect_to invitation_path(token: params[:invitation_token]) and return
      end

      send_email_verification
      flash.now[:notice] = "Please verify your inbox to proceed"
      render :new, status: :created
    else
      flash.now[:alert] = "There is an account with this email. Please sign in."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end

  def send_email_verification
    UserMailer.with(user: @user).email_verification.deliver_later
  end

  def has_valid_invitation_token?
    InvitationService.instance.verify_invitation(params[:invitation_token]).present?
  end
end
