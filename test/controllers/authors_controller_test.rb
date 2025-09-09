require_relative "../test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  # todo: add cancancan tests

  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get authors_url
    assert_response :success
  end

  test "should get edit" do
    sign_in_as(users(:lazaro_nixon))
    get edit_author_url(authors(:one))
    assert_response :success
  end

  test "should update author" do
    sign_in_as(users(:lazaro_nixon))
    patch author_url(authors(:one)), params: { author: { first_name: "Updated Name" } }
    assert_redirected_to authors_url

    authors(:one).reload
    assert_equal "Updated Name", authors(:one).first_name
  end

  test "should not update author if email is empty or invalid" do
    sign_in_as(users(:lazaro_nixon))
    patch author_url(authors(:one)), params: { author: { email: "" } }
    assert_response :unprocessable_entity
    assert_equal "Email can't be blank and Email is invalid", flash[:alert]

    patch author_url(authors(:one)), params: { author: { email: "invalid" } }
    assert_response :unprocessable_entity
    assert_equal "Email is invalid", flash[:alert]
  end

  test "should deactivate author" do
    sign_in_as(users(:lazaro_nixon))

    assert authors(:one).active
    put deactivate_author_url(authors(:one))
    assert_redirected_to authors_url

    authors(:one).reload
    assert_not authors(:one).active
  end
end