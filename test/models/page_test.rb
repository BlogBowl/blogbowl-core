require_relative "../test_helper"

class PageTest < ActiveSupport::TestCase
  test "should get authors" do
    blog = pages(:one)
    authors = blog.authors

    assert_includes authors, authors(:one)
  end

  test "should not create without slug" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'test name')
    assert_not new_blog.save
  end

  test "should not create without name" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(slug: 'without-name')
    assert_not new_blog.save
  end

  test "should not create page with existing name" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(slug: 'blog', name: 'Blog')
    assert_not new_blog.save
  end

  test "should update to existing slug" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'test name', slug: 'update-slug-exists')
    assert new_blog.save
    assert new_blog.name_slug, "test-name"
    new_blog.update(slug: 'blog')
    new_blog.reload
    assert new_blog.slug, 'blog'
  end

  test "should remove slash from slug" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'test name', slug: '/slashed-slug')
    assert new_blog.save
    assert_equal new_blog.slug, 'slashed-slug'
  end

  test "should create page with domain assigned after created" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'test name', slug: '/blog-domain')
    assert new_blog.save
    assert_includes new_blog.domain, ".blogbowl.app"
  end

  test "should generate name_slug on page create" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'new-blog', slug: 'blog')
    assert new_blog.save
    assert new_blog.name_slug, "new-blog"
  end

  test "should regenerate name_slug on page name change" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'new-blog', slug: 'blog')
    assert new_blog.save
    assert new_blog.name_slug, "new-blog"
    new_blog.update(name: 'Updated page')
    new_blog.reload
    assert new_blog.name_slug, "updated-page"
  end

  test "allow same names across different workspaces" do
    workspace_one = workspaces(:one)
    workspace_one_page = workspace_one.pages.create(name: 'My blog', slug: 'blog')
    assert workspace_one_page.save
    assert workspace_one_page.name_slug, "my-blog"

    workspace_two = workspaces(:two)
    workspace_two_page = workspace_two.pages.create(name: 'My blog', slug: 'blog')
    assert workspace_two_page.save
    assert workspace_two_page.name_slug, "my-blog"
  end

  test "can not update to existing name" do
    workspace = workspaces(:one)
    new_blog = workspace.pages.create(name: 'New blog', slug: 'blog')
    assert new_blog.save

    assert_not new_blog.update(name: 'Blog')
    new_blog.reload
    assert new_blog.name, "New blog"
    assert new_blog.name_slug, "new-blog"
  end

  test "should create post with revision" do
    page = pages(:one)

    cover_image_url = "https://blogbowl-ai-prod.sfo3.cdn.digitaloceanspaces.com/other/top-10-free-blog-platforms.webp"

    category_id = page.categories.first.id
    author_id = page.authors.first.id
    post = page.create_post_with_revision(
      "This is title",
      "<p>Test html over here</p>",
      JSON.parse('{"type":"doc","content":[{"type":"paragraph","attrs":{"class":null,"textAlign":null},"content":[{"type":"text","text":"Test htlm over here"}]}]}'),
      "This is description",
      category_id,
      author_id,
      cover_image_url,
      true
    )

    assert post.title, "This is title"
    assert post.content_html, "<p>Test html over here</p>"
    assert post.content_json, JSON.parse('{"type":"doc","content":[{"type":"paragraph","attrs":{"class":null,"textAlign":null},"content":[{"type":"text","text":"Test htlm over here"}]}]}')
    assert post.category_id, category_id
    assert post.authors.first.id, author_id
    assert post.status, "published"
    assert post.cover_image.attached?, true
  end

  test "post with revision should not be published" do
    page = pages(:one)

    cover_image_url = "https://blogbowl-ai-prod.sfo3.cdn.digitaloceanspaces.com/other/top-10-free-blog-platforms.webp"

    category_id = page.categories.first.id
    author_id = page.authors.first.id
    post = page.create_post_with_revision(
      "This is title",
      "<p>Test html over here</p>",
      JSON.parse('{"type":"doc","content":[{"type":"paragraph","attrs":{"class":null,"textAlign":null},"content":[{"type":"text","text":"Test htlm over here"}]}]}'),
      "This is description",
      category_id,
      author_id,
      cover_image_url,
      false
    )

    assert post.title, "This is title"
    assert post.content_html, "<p>Test html over here</p>"
    assert post.content_json, JSON.parse('{"type":"doc","content":[{"type":"paragraph","attrs":{"class":null,"textAlign":null},"content":[{"type":"text","text":"Test htlm over here"}]}]}')
    assert post.category_id, category_id
    assert post.authors.first.id, author_id
    assert post.status, "draft"
    assert post.cover_image.attached?, true
  end

end
