class Newsletters::SettingsController < Newsletters::ApplicationController
  layout 'newsletter_dashboard'
  before_action -> { authorize! :manage, @workspace }

  def show
  end

  private

  def current_ability
    @current_ability ||= WorkspaceAbility.new(current_user)
  end

end
