require_relative "../test_helper"

class MembersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get members_path
    assert_response :success
    assert_select "h1", "Members"
  end

  test "should render all members" do
    sign_in_as(users(:lazaro_nixon))
    blog = pages(:one)
    members = blog.members

    get members_path
    assert_response :success

    members.each do |member|
      assert_select "p", member.formatted_name
    end
  end

  test "should get edit" do
    sign_in_as(users(:lazaro_nixon))
    get edit_member_path(members(:one))
    assert_response :success
    assert_select "h1", "Member permissions"
    assert_select "h3", members(:one).user.formatted_name
  end

  test "should update member" do
    sign_in_as(users(:lazaro_nixon))
    member = members(:one)
    posts_role = "editor"

    patch member_path(member), params: { posts_role: posts_role }
    assert_redirected_to members_path
    assert_equal "Member was updated successfully.", flash[:notice]
  end

  test "should not update member if writer is without an author" do
    sign_in_as(users(:lazaro_nixon))
    member = members(:one)

    patch member_path(member), params: { posts_role: "writer", posts_has_own_author: nil }
    assert_response :unprocessable_entity
    assert_equal "Writer can't be without an author", flash[:alert]
  end

  test "should not update member if posts role is blank" do
    sign_in_as(users(:lazaro_nixon))
    member = members(:one)

    patch member_path(member), params: {  }
    assert_response :bad_request
    assert_equal "Posts role can't be blank", flash[:alert]
  end

  test "should not update member if posts role is invalid" do
    sign_in_as(users(:lazaro_nixon))
    member = members(:one)

    patch member_path(member), params: { posts_role: "invalid" }
    assert_response :bad_request
    assert_equal "Posts role is invalid", flash[:alert]
  end

  # TODO: PRO
  # test "should invite new user on PRO plans" do
  #   sign_in_as(users(:pro_user))
  #
  #   workspace = workspaces(:pro_workspace)
  #   assert workspace.members.count, 1
  #
  #   post members_path, params: { email: 'super-test@test.com', posts_role: 'writer' }
  #   assert_redirected_to members_path
  #   assert_equal flash[:notice], "Invitation was sent successfully."
  # end
  #
  # test "should not invite new user on free plans" do
  #   sign_in_as(users(:free_user))
  #
  #   workspace = workspaces(:free_workspace)
  #   assert workspace.members.count, 1
  #
  #   post members_path, params: { email: 'super-test@test.com', posts_role: 'writer' }
  #   assert_response :unprocessable_entity
  #   assert_equal flash[:alert], "To invite new member, please, upgrade to a paid plan!"
  # end
end