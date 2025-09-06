class Sessions::PasswordlessesController < ApplicationController
  skip_before_action :authenticate

  before_action :set_user, only: :edit

  def new
  end

  def edit
    session_record = @user.sessions.create!
    set_session_cookie(session_record)

    revoke_tokens; redirect_to(root_path)
  end

  def create
    if @user = User.find_by(email: params[:email], verified: true)
      send_passwordless_email
      flash[:notice] = "Check your email for sign in instructions"
      redirect_to sign_in_path
    else
      flash[:alert] = "You can't sign in until you verify your email"
      redirect_to new_sessions_passwordless_path
    end
  end

  private
  def set_user
    token = SignInToken.find_signed!(params[:sid]); @user = token.user
  rescue StandardError
    flash[:alert] = "That sign in link is invalid"
    redirect_to new_sessions_passwordless_path
  end

  def send_passwordless_email
    UserMailer.with(user: @user).passwordless.deliver_later
  end

  def revoke_tokens
    @user.sign_in_tokens.delete_all
  end
end
