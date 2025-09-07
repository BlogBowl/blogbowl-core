class WorkspaceAbility
  include CanCan::Ability

  def initialize(user)
    can :manage, Workspace do |workspace|
      workspace.owner?(user)
    end
  end
end
