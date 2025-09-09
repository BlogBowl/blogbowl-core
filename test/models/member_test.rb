require_relative "../test_helper"

class MemberTest < ActiveSupport::TestCase
  test "should create a new author when create_or_activate_author! is called and no author is present" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:one)
    member = workspace.member_of_user(user)

    assert_nil member.author
    member.create_or_activate_author!

    member.reload

    assert_not_nil member.author
  end

  test "should deactivate author when deactivate_author! is called and author is present" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:one)
    member = workspace.member_of_user(user)

    assert_nil member.author
    member.create_or_activate_author!

    member.deactivate_author!
    member.reload

    assert_not member.author.active
  end

  test "should activate author when create_or_activate_author! is called and author is present" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:one)
    member = workspace.member_of_user(user)

    assert_nil member.author
    member.create_or_activate_author!

    member.deactivate_author!

    assert_not member.author.active
    member.create_or_activate_author!
    member.reload

    assert member.author.active
  end

  test "should return formatted name of a user" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:one)
    member = workspace.member_of_user(user)

    assert_equal user.formatted_name, member.formatted_name
  end

  test "should return nil from member_of_user if user is not a member" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:two)
    member = workspace.member_of_user(user)

    assert_nil member
  end

  test "should not return nil from member_of_user if user is a member" do
    user = users(:lazaro_nixon)
    workspace = workspaces(:one)
    member = workspace.member_of_user(user)

    assert_not_nil member
  end
end
