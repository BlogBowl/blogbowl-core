module SessionsControllerConcern
  extend ActiveSupport::Concern

  included do
    layout "authentication"

    skip_before_action :authenticate, only: %i[ new create ]

    before_action :set_session, only: :destroy
  end

  def index
    @sessions = current_user.sessions.order(created_at: :desc)
  end

  def new
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      @session = user.sessions.create!
      set_session_cookie(@session)

      redirect_to root_path
    else
      flash[:alert] = "That email or password is incorrect"
      redirect_to sign_in_path(email_hint: params[:email])
    end
  end

  def destroy
    @session.destroy
    cookies.delete(:session_token)
    session[:workspace_id] = nil
    Current.workspace_id = nil
    flash[:notice] = "That session has been logged out"
    redirect_to(sessions_path)
  end

  private

  def set_session
    @session = current_user.sessions.find(params[:id])
  end

end