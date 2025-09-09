require_relative "../../../test_helper"

class API::Internal::AuthorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get api_internal_authors_path
    assert_response :success
    assert_equal @response.body, pages(:one).authors.as_json.to_json
  end
end
