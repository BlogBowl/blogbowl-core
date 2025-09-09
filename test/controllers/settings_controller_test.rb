require_relative "../test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test "should render not found if can't manage workspace" do
    sign_in_as(users(:writer_without_blog))
    get settings_url
    assert_response :not_found
  end
end
