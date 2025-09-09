require_relative "../test_helper"

class PostTest < ActiveSupport::TestCase

  test "should save post" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content")
    assert post.save, post.errors.full_messages
  end

  test "should not save post without title if published" do
    post = pages(:one).posts.new(content_html: "This is a test content", status: "published")
    assert_not post.save, "Saved the post without a title"
  end

  test "should generate slug on creation" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content")
    post.save
    assert_not_nil post.slug, "Did not generate slug"
  end

  test "should generate unique slug on creation" do
    title = "This is a test title"
    post = pages(:one).posts.new(title: title, content_html: "This is a test content")
    post.save
    post2 = pages(:one).posts.new(title: title, content_html: "This is a test content")
    post2.save
    assert_not_equal post.slug, post2.slug, "Did not generate unique slug"
    assert_equal  title.parameterize, post.slug, "First slug is incorrect"
    assert_equal "#{title.parameterize}-1", post2.slug, "Second slug is incorrect"
  end

  test "should update slug on title change" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content")
    post.save
    new_title = "This is an updated test title"
    post.update(title: new_title)
    assert_equal new_title.parameterize, post.slug, "Did not update slug"
  end

  test "can exist same slug on different pages" do
    title = "This is a test title"
    post = pages(:one).posts.new(title: title, content_html: "This is a test content")
    post.save
    post2 = pages(:two).posts.new(title: title, content_html: "This is a test content")
    post2.save
    assert_equal post.slug, post2.slug, "Did not generate unique slug"
  end

  test "should not update slug on title change if published" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content", status: "published", authors: [authors(:one)])
    post.save
    post.update(title: "This is an updated test title")
    assert_not_equal "This is an updated test title".parameterize, post.slug, "Updated slug"
  end

  test "should update slug on title change if not published" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content", status: "draft")
    post.save
    post.update(title: "This is an updated test title")
    assert_equal "This is an updated test title".parameterize, post.slug, "Did not update slug"
  end

  test "should not save post without author if published" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content", status: "published")
    assert_not post.save, "Saved the post without author"
  end

  test "should set last revision as history if published" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content", authors: [authors(:one)])
    post.save
    post.new_revision.save
    post.new_revision.save

    post.publish!
    assert_equal 2, post.post_revisions.count, "Revision count doesn't match"
    assert_equal "draft", post.post_revisions[-2].kind, "Pre-last revision is not draft"
    assert_equal "history", post.post_revisions.last.kind, "Last revision is not history"
  end

  test "should not create new revision if last revision is the same as the pre-last one" do
    post = pages(:one).posts.new(title: "This is a test title", content_html: "This is a test content")
    post.save
    post.new_revision.save
    post.new_revision.save
    post.new_revision.save

    assert_equal 2, post.post_revisions.count, "Revision count doesn't match"
  end

  test "should set first_published_at only on first post publish" do
    post = pages(:one).posts.new(title: "Testing first publish at", content_html: "Testing first publish at", authors: [authors(:one)])
    post.save
    post.new_revision.save

    post.publish!

    first_published_at = post.first_published_at
    assert_equal post.status, "published"
    assert_not_nil post.first_published_at

    post.publish!
    assert_equal post.first_published_at, first_published_at
  end
end
