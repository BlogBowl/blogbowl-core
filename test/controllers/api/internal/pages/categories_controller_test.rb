require_relative "../../../../test_helper"

class API::Internal::Pages::CategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:one)
  end

  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get api_internal_pages_categories_url(page_id: @page.id)
    assert_response :success
    assert_equal @response.body, @page.categories.as_json.to_json
  end

  test "should create category" do
    sign_in_as(users(:lazaro_nixon))
    assert_difference -> { @page.categories.count } do
      post api_internal_pages_categories_url(page_id: @page.id), params: {  name: "New Category" }
    end
    assert_response :success
  end
end
