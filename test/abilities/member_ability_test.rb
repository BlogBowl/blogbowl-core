require_relative "../test_helper"

class MemberAbilityTest < ActiveSupport::TestCase
  test "owner can manage members" do
    user = users(:lazaro_nixon)
    ability = MemberAbility.new(user)

    assert ability.can?(:manage, members(:one))
    assert ability.can?(:manage, members(:two))
    assert ability.can?(:manage, members(:three))
  end

  test "regular member can't manage members" do
    user = users(:editor_without_blog)
    ability = MemberAbility.new(user)

    assert ability.cannot?(:manage, members(:one))
    assert ability.cannot?(:manage, members(:two))
    assert ability.cannot(:manage, members(:three))
  end
end
