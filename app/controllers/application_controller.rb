class ApplicationController < ActionController::Base
  # include Authentication
  include CoreHelper
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate
  before_action :set_workspace, if: -> { Current.session.present? }

  def render_not_found
    render :file => "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end

  def has_available_session?
    Session.find_by_id(cookies.signed[:session_token]).present?
  end

  def set_session_cookie(session)
    cookie_domain = ['', 'analytics.'].map do |subdomain|
      subdomain + Rails.application.routes.default_url_options[:host]
    end
    cookies.signed.permanent[:session_token] =
      { value: session.id, httponly: true, domain: cookie_domain }
  end

  rescue_from CanCan::AccessDenied do
    render_not_found
  end

  private

  def authenticate
    session_record = Session.find_by_id(cookies.signed[:session_token])
    if session_record.present?
      # TODO: PRO
      # if session_record.user.verified?
      #   Current.session = session_record
      # else
      #   flash[:alert] = "Please verify your email address before signing in"
      #   redirect_to sign_in_path
      # end
      Current.session = session_record
      return
    end
    redirect_to sign_in_path
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.workspace_id = session[:workspace_id]
  end

  def require_sudo
    unless Current.session.sudo?
      redirect_to new_sessions_sudo_path(proceed_to_url: request.original_url)
    end
  end

  def set_workspace
    if Current.workspace_id.present?
      @workspace = Current.session.user.workspaces.find_by(id: Current.workspace_id)
      @workspace = Current.session.user.workspaces.first if @workspace.nil?
    else
      @workspace = Current.session.user.workspaces.first
      Current.workspace_id = @workspace.id
    end
  end
end
