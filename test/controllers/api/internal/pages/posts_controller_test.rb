require_relative "../../../../test_helper"

class API::Internal::Pages::PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = workspaces(:one).pages.find_by(slug: 'blog')
  end

  test "should create post" do
    sign_in_as(users(:lazaro_nixon))
    assert_difference('Post.count') do
      post api_internal_pages_posts_url(page_id: @page.id), params: { title: 'Hello world!' }, as: :json
    end
    assert_response :created
  end

  test "should publish post, when author set" do
    sign_in_as(users(:lazaro_nixon))
    assert_not posts(:post_with_authors).published?

    post api_internal_pages_post_publish_url(page_id: @page.id, post_id: posts(:post_with_authors).id)
    posts(:post_with_authors).reload

    assert_response :ok
    assert posts(:post_with_authors).published?
  end

  test "should not publish post, when author is not set" do
    sign_in_as(users(:lazaro_nixon))
    assert_not posts(:one).published?

    post api_internal_pages_post_publish_url(page_id: @page.id, post_id: posts(:one).id)
    posts(:one).reload

    assert_response :unprocessable_entity
    assert_not posts(:one).published?
  end

  test "should update post" do
    sign_in_as(users(:lazaro_nixon))

    patch api_internal_pages_post_url(page_id: @page.id, id: posts(:one).id), params: { title: 'Hello world!' }, as: :json
    posts(:one).reload

    assert_response :ok
    assert_equal 'Hello world!', posts(:one).title
  end

  test "should not delete authors from post if none sent" do
    sign_in_as(users(:lazaro_nixon))
    posts(:one).update(authors: [authors(:one)])

    patch api_internal_pages_post_url(page_id: @page.id, id: posts(:one).id), params: { title: 'Hello world!' }, as: :json
    posts(:one).reload

    assert_response :ok
    assert_equal 1, posts(:one).authors.count
  end

  test "should delete authors from post if empty array is sent" do
    sign_in_as(users(:lazaro_nixon))
    posts(:one).update(authors: [authors(:one)])

    patch api_internal_pages_post_url(page_id: @page.id, id: posts(:one).id), params: { title: 'Hello world!', author_ids: [] }, as: :json
    posts(:one).reload

    assert_response :ok
    assert_equal 0, posts(:one).authors.count
  end

  test "should update authors of post" do
    sign_in_as(users(:lazaro_nixon))
    posts(:one).update(authors: [authors(:one)])

    patch api_internal_pages_post_url(page_id: @page.id, id: posts(:one).id), params: { title: 'Hello world!', author_ids: [authors(:without_name).id] }, as: :json
    posts(:one).reload

    assert_response :ok
    assert_equal 1, posts(:one).authors.count
    assert_equal authors(:without_name), posts(:one).authors.first
  end
end
