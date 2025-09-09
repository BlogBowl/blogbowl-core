require_relative "../test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
    sign_in_as(@user)
    @workspace = workspaces(:one)
    @default_page = @workspace.pages.find_by(name_slug: 'blog')
  end

  test "should get index" do
    sign_in_as(users(:lazaro_nixon))
    get pages_posts_path(@default_page)
    assert_response :success
  end

  test "should get new" do
    sign_in_as(users(:lazaro_nixon))
    get new_pages_post_path(@default_page)
    assert_response :success
  end

  test "should not set an author when creating a post if current user's member does not have an active author" do
    user = users(:lazaro_nixon)
    sign_in_as(user)
    member = @workspace.member_of_user(user)
    assert_nil member.author

    post pages_posts_path(@default_page), params: { post: { content: "This is a test content", title: "This is a test title" } }
    assert_empty @default_page.posts.last.authors
  end
end
