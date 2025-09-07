class MasqueradesController < ApplicationController
  before_action :authorize_admin_for_masquerade, only: [:create]
  before_action :authorize_masquerade_session, only: [:destroy]
  before_action :set_user, only: :create

  def create
    session[:admin_id] = current_user.id

    session_record = @user.sessions.create!
    set_session_cookie(session_record)

    flash[:notice] = "Successfully impersonating #{@user.email}"
    redirect_to root_path
  end

  def destroy
    admin_id = session.delete(:admin_id)
    admin = User.find(admin_id)

    session_record = admin.sessions.create!
    set_session_cookie(session_record)

    flash[:notice] = "Stopped impersonating."
    redirect_to admin_users_path
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def authorize_admin_for_masquerade
    unless current_user&.email&.ends_with?('@blogbowl.io')
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(root_path)
    end
  end

  def authorize_masquerade_session
    unless session[:admin_id]
      flash[:alert] = "Not in a masquerade session."
      redirect_to(root_path)
    end
  end
end