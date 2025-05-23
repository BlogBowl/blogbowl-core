class MemberAbility
  include CanCan::Ability

  def initialize(user)
    can :manage, Member do |member|
      workspace = member.workspace
      workspace.owner?(user)
    end
  end
end
