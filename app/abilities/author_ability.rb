class AuthorAbility
  include CanCan::Ability

  def initialize(user)
    can :edit, Author do |author|
      next true if author.member.workspace.owner?(user)
      author.member.user == user
    end
  end
end
