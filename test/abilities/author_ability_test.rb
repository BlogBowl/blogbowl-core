require_relative "../test_helper"

class AuthorAbilityTest < ActiveSupport::TestCase
  test "workspace owner can edit authors in own workspace" do
    user = users(:lazaro_nixon)
    ability = AuthorAbility.new(user)

    assert ability.can?(:edit, authors(:one))
  end

  test "workspace owner cannot edit authors in other workspaces" do
    user = users(:lazaro_nixon)
    ability = AuthorAbility.new(user)

    assert ability.cannot?(:edit, authors(:from_blog_two))
  end

  test "member can edit own author" do
    user = users(:editor_without_blog)
    ability = AuthorAbility.new(user)

    assert ability.can?(:edit, authors(:one))
  end

  test "member cannot edit other authors" do
    user = users(:editor_without_blog)
    ability = AuthorAbility.new(user)

    assert ability.cannot?(:edit, authors(:without_name))
  end
end
