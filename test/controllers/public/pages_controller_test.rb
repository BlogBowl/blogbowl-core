require_relative "../../test_helper"

class Public::PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get index if domain is assigned to a blog" do
    blog = pages(:blog_with_domain_1)
    blog.create_settings(title: "Test Title", template: 'basic') unless blog.settings
    host! blog.domain

    get public_root_path(blog)
    assert_response :success
  end

  # test "should get not found if domain is not assigned to a blog" do
  #   host! "unassigned-domain.example.com"
  #
  #   get root_path
  #   assert_response :not_found
  # end
end
