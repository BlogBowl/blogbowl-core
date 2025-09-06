class Sessions::OmniauthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate

  def create
    @user = User.create_with(user_params).find_or_initialize_by(omniauth_params)
    is_new_user = !@user.persisted?

    if @user.save
      session_record = @user.sessions.create!
      set_session_cookie(session_record)

      if is_new_user
        # Here we add user to our subscribers
        subscribe_user_to_newsletter(@user)

        @workspace = @user.workspaces.first
        redirect_to pages_ai_content_plan_path(@workspace.pages.first)
      else
        redirect_to root_path
      end
    else
      flash[:alert] = "Authentication failed"
      redirect_to sign_in_path
    end
  end

  def failure
    flash[:alert] = params[:message]
    redirect_to sign_in_path
  end

  private
  def user_params
    { email: omniauth.info.email, password: SecureRandom.base58, verified: true }
  end

  def omniauth_params
    { provider: omniauth.provider, uid: omniauth.uid }
  end

  def omniauth
    request.env["omniauth.auth"]
  end
end
