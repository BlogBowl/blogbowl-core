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
    member = members(:one)
    get edit_member_path(member)
    assert_response :success
    assert_select "h1", "Edit member #{member.user.email}"
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

    patch member_path(member), params: {}
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

  test "should create new member" do
    sign_in_as(users(:lazaro_nixon))

    post members_path, params: {
      email: 'test@test.com',
      password: 'admin1234',
      password_confirmation: 'admin1234',
      posts_role: 'writer',
      posts_has_own_author: true,
    }

    user = User.find_by(email: 'test@test.com')
    assert_redirected_to members_path
    assert_equal flash[:notice], "User was successfully created."
    assert_equal user.workspaces.count, 1

    # user can login
    post(sign_in_url, params: { email: 'test@test.com', password: "admin1234" })
    assert_redirected_to root_url
  end

  test "should not create new member if passwords do not match" do
    sign_in_as(users(:lazaro_nixon))

    post members_path, params: {
      email: 'test@test.com',
      password: 'admin1234',
      password_confirmation: 'admin',
      posts_role: 'writer',
      posts_has_own_author: true
    }

    assert_response :unprocessable_entity
    assert_equal flash[:alert], "Password confirmation doesn't match Password"
  end

  test "should not create new member if already member of organization" do
    sign_in_as(users(:lazaro_nixon))

    post members_path, params: {
      email: 'test@test.com',
      password: 'admin1234',
      password_confirmation: 'admin1234',
      posts_role: 'writer',
      posts_has_own_author: true
    }

    assert_redirected_to members_path

    post members_path, params: {
      email: 'test@test.com',
      password: 'admin1234',
      password_confirmation: 'admin1234',
      posts_role: 'writer',
      posts_has_own_author: true,
    }

    assert_response :unprocessable_entity
    assert_equal flash[:alert], "This user is already a member of this workspace."
  end

  test "should update user's password" do
    sign_in_as(users(:lazaro_nixon))

    member = members(:one)
    posts_role = "editor"

    patch member_path(member), params: {
      posts_role: posts_role,
      email: 'newemail@example.com',
      password: 'admin1234',
      password_confirmation: 'admin1234',
      posts_has_own_author: true,
    }

    assert_redirected_to members_path
    assert_equal "Member was updated successfully.", flash[:notice]

    post(sign_in_url, params: { email: member.user.email, password: "admin1234" })
    assert_redirected_to root_url
  end
end