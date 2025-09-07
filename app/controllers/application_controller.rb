class ApplicationController < ActionController::Base
  include Authentication
  include CoreHelper
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :set_workspace, if: -> { authenticated? }

  def set_workspace
    @workspace = Current.session.user.workspaces.first
  end

  def render_not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end
end
