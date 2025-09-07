# frozen_string_literal: true

class PostAbility
  include CanCan::Ability

  def initialize(user)
    can :create, Post do |post|
      generic_rule(user, post, "posts:create", try_own: false)
    end

    can :edit, Post do |post|
      generic_rule(user, post, "posts:edit")
    end

    can :destroy, Post do |post|
      generic_rule(user, post, "posts:destroy")
    end
  end

  private

  def generic_rule(user, post, permission, try_own: true)
    workspace = post.page.workspace
    return true if workspace.owner?(user)

    permissions = workspace.permissions(user)
    return false unless permissions

    return true if permissions.include?(permission)
    return false unless try_own

    permissions.include?("#{permission}_own") && post.authors.include?(workspace.member_of_user(user).author)
  end
end
