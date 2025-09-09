require_relative "../test_helper"

class WorkspacesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:alex_gonzalez))
    (workspace1, workspace2) = users(:alex_gonzalez).workspaces

    get workspaces_url
    assert_response :success
    assert_select "h2", workspace1.title
    assert_select "h2", workspace2.title
  end

  test "should redirect to blog if can access a workspace" do
    sign_in_as(users(:lazaro_nixon))
    workspace = users(:lazaro_nixon).workspaces.first
    get workspace_url(workspace)
    assert_redirected_to pages_path
  end

  test "should render not found if can't access a workspace" do
    sign_in_as(users(:lazaro_nixon))
    workspace = workspaces(:two)
    get workspace_url(workspace)
    assert_response :not_found
  end
end