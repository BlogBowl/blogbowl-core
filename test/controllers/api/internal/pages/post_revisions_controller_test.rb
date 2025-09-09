require_relative "../../../../test_helper"

class API::Internal::Pages::PostRevisionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:one)
    @workspace = @page.workspace
  end

  test "should create post revision" do
    sign_in_as(users(:lazaro_nixon))
    assert_difference('PostRevision.count') do
      post api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id), params: { post_revision: { title: "New title" } }, as: :json
    end
    assert_response :created
  end

  test "should update last post revision" do
    sign_in_as(users(:lazaro_nixon))
    posts(:one).new_revision.save

    patch last_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id), params: { title: "New title 2" }, as: :json
    assert_response :ok

    assert_equal "New title 2", posts(:one).post_revisions.last.title
  end

  test "should not update last post revision if post has no any" do
    sign_in_as(users(:lazaro_nixon))
    patch last_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id), params: { post_revision: { title: "New title 2" } }, as: :json
    assert_response :conflict
  end

  test "should show last" do
    sign_in_as(users(:lazaro_nixon))
    posts(:one).new_revision.save
    get last_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id)
    assert_response :ok
  end

  test "should return not found if last doesn't exist" do
    sign_in_as(users(:lazaro_nixon))
    get last_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id)
    assert_response :not_found
  end

  test "should apply post revision" do
    sign_in_as(users(:lazaro_nixon))
    revision = posts(:one).new_revision
    revision.title = "Apply me"
    revision.save

    post last_apply_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id)
    posts(:one).reload

    assert_response :ok
    assert_equal "Apply me", posts(:one).title
  end

  test "should not apply and return conflict if last doesn't exist" do
    sign_in_as(users(:lazaro_nixon))
    post last_apply_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id)
    assert_response :conflict
  end

  test "should create preview, when author set" do
    sign_in_as(users(:lazaro_nixon))
    post = posts(:post_with_authors)

    assert_not_empty post.authors

    revision = post.new_revision
    revision.title = "Revision should be shared"
    revision.save

    assert_nil revision.share_id
    post last_share_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:post_with_authors).id)
    revision.reload

    assert_response :ok
    assert_not_nil revision.share_id
    assert_not_nil revision.shared_at
  end

  test "should not create preview, when author not set" do
    sign_in_as(users(:lazaro_nixon))
    post = posts(:one)

    assert_empty post.authors

    revision = post.new_revision
    revision.title = "Revision should be shared"
    revision.save

    assert_nil revision.share_id
    post last_share_api_internal_pages_post_revisions_url(page_id: @page.id, post_id: posts(:one).id)
    revision.reload

    assert_response :unprocessable_entity
    assert_nil revision.share_id
    assert_nil revision.shared_at
  end
end
