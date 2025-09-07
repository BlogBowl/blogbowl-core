require_relative "../test_helper"

class AuthorTest < ActiveSupport::TestCase
  test "should not save author with invalid email" do
    user = users(:lazaro_nixon)
    blog = pages(:one)
    member = blog.workspace.member_of_user(user)

    author = Author.create(email: "wrong email", member: member)
    assert_not author.save
  end

  test "should save author with valid email" do
    user = users(:lazaro_nixon)
    blog = pages(:one)
    member = blog.workspace.member_of_user(user)

    author = Author.create(email: "hello@example.com", member: member)
    assert author.save, author.errors.full_messages
  end

  test "should return correct formatted name (w/ names)" do
    author = authors(:one)
    assert_equal "Pipyau Ivanovich", author.formatted_name
  end

  test "should return correct formatted name (w/o names)" do
    author = authors(:without_name)
    assert_equal "noblog2@example.com", author.formatted_name
  end

  test "should create slug on author create (w/o names) and update" do
    user = users(:alex_gonzalez)
    blog = pages(:two)
    member = blog.workspace.member_of_user(user)
    author = Author.create(email: "test@slug.com", member: member)
    assert_not_empty author.slug

    success = author.update(first_name: "Peter", last_name: "Pan")

    assert_equal author.slug, "peter-pan"

    success = author.update(first_name: "Alexander", last_name: "Gonzales")

    assert_equal author.slug, "alexander-gonzales"
  end

  test "should create slug on author create (w names) and update" do
    user = users(:alex_gonzalez)

    blog = pages(:blog_with_domain_1)

    member = blog.workspace.member_of_user(user)

    author = Author.create(email: "test2@slug.com", first_name: "Peter", last_name: "Pan", member: member)
    assert_not_empty author.slug
    assert_equal author.slug, "peter-pan"

    author.update(first_name: "Alexander", last_name: "Gonzales")

    assert_equal author.slug, "alexander-gonzales"
  end

  test "should not create authors with the same names (slug should be unique across one workspace)" do
    user = users(:alex_gonzalez)
    second_user = users(:member_without_blog)

    blog = pages(:blog_with_domain_1)

    member = blog.workspace.member_of_user(user)
    second_member = blog.workspace.member_of_user(second_user)

    author = Author.create(email: "test2@slug.com", first_name: "Parker", last_name: "Parker", member: member)
    second_author = Author.create(email: "test3@slug.com", first_name: "Parker", last_name: "Parker", member: second_member)
    assert_not second_author.save
  end

  test "should not update authors with the same names (slug should be unique across one workspace)" do
    user = users(:alex_gonzalez)
    second_user = users(:member_without_blog)

    blog = pages(:blog_with_domain_1)

    member = blog.workspace.member_of_user(user)
    second_member = blog.workspace.member_of_user(second_user)

    author = Author.create(email: "test2@slug.com", first_name: "Peter", last_name: "Pan", member: member)
    second_author = Author.create(email: "test3@slug.com", first_name: "Test", last_name: "Second", member: second_member)
    assert_not_empty author.slug
    assert_equal author.slug, "peter-pan"
    assert_not_empty second_author.slug
    assert_equal second_author.slug, "test-second"

    second_author.update(first_name: "Peter", last_name: "Pan")

    assert_equal second_author.slug, "test-second"
  end

  test "should create author with same names across different workspaces" do
    user = users(:alex_gonzalez)
    second_user = users(:member_without_blog)

    blog = pages(:blog_with_domain_1)
    second_blog = pages(:two)


    member = blog.workspace.member_of_user(user)
    second_member = second_blog.workspace.member_of_user(second_user)

    author = Author.create(email: "test@slug.com", first_name: "Peter", last_name: "Pan", member: member)
    second_author = Author.create(email: "test@slug.com", first_name: "Peter", last_name: "Pan", member: second_member)

    assert_not_empty author.slug
    assert_equal author.slug, "peter-pan"
    assert_not_empty second_author.slug
    assert_equal second_author.slug, "peter-pan"
  end
end