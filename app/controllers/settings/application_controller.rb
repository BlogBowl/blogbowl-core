class Settings::ApplicationController < ApplicationController
  layout 'dashboard'

  before_action :set_settings
  before_action -> { authorize! :manage, @workspace }

  private

  def current_ability
    @current_ability ||= WorkspaceAbility.new(current_user)
  end

  def set_settings
    @workspace_settings = @workspace.settings
  end
end
