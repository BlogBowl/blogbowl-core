require_relative "../test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect from root to first blog posts" do
    sign_in_as(users(:lazaro_nixon))
    get root_url
    assert_redirected_to pages_path
  end

  test "should create new pages" do
    sign_in_as(users(:lazaro_nixon))

    workspace = workspaces(:one)

    assert workspace.pages.count, 1

    assert_difference -> { workspace.pages.count }, 1 do
      post pages_path, params: { page: { name: 'test', slug: 'test' } }
    end
  end

  test "should show warning to change password for default user" do
    sign_in_as_pas(users(:default_user), 'changeme')

    get pages_path
    assert_response :success

    assert_select "h3", "Change default user password"
  end

  test "should not show warning to change password for default user" do
    sign_in_as(users(:lazaro_nixon))

    get pages_path
    assert_response :success

    assert_select "h3", text: "Change default user password", count: 0
  end
end
