require_relative "../test_helper"

class PostAuthorTest < ActiveSupport::TestCase
  test "post can have multiple authors" do
    blog = pages(:one)
    post = blog.posts.create(title: "Post title", content_html: "Post content")

    author1 = blog.authors.first
    author2 = blog.authors.second

    post.post_authors.build(author: author1, role: 'author')
    post.post_authors.build(author: author2, role: 'author')
    assert post.save, post.errors.full_messages
  end

  test "post can have author only from the same blog" do
    blog = pages(:one)
    post = blog.posts.create(title: "Post title", content_html: "Post content")
    assert post.save, post.errors.full_messages

    author_from_another_blog = pages(:two).workspace.authors.first
    post.post_authors.build(author: author_from_another_blog)
    assert_not post.save
  end
end
