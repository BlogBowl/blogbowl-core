class Newsletters::Settings::ApplicationController < Newsletters::ApplicationController
  layout 'newsletter_dashboard'
  before_action -> { authorize! :manage, @workspace }

  private

  def current_ability
    @current_ability ||= WorkspaceAbility.new(current_user)
  end
end
