require_relative "../test_helper"

class WorkspaceAbilityTest < ActiveSupport::TestCase
  test "owner can manage workspace" do
    user = users(:lazaro_nixon)
    ability = WorkspaceAbility.new(user)

    assert ability.can?(:manage, workspaces(:one))
  end

  test "can not manage workspace if not owner" do
    user = users(:lazaro_nixon)
    ability = WorkspaceAbility.new(user)

    assert ability.cannot?(:manage, workspaces(:two))
  end
end
