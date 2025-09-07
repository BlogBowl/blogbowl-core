class SettingsController < ApplicationController
  layout 'dashboard'

  before_action -> { authorize! :manage, @workspace }

  def show
  end

  private

  def current_ability
    @current_ability ||= WorkspaceAbility.new(current_user)
  end

end
