class Pages::Settings::ApplicationController < Pages::ApplicationController
  before_action -> { authorize! :manage, @workspace }

  private

  def current_ability
    @current_ability ||= WorkspaceAbility.new(current_user)
  end
end
