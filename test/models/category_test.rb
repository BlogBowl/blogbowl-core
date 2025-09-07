require_relative "../test_helper"

class CategoryTest < ActiveSupport::TestCase
  # /blog enitity should be created before test

  test "should save category" do
    category = pages(:one).categories.new(name: "This is a test category")
    assert category.save, category.errors.full_messages
  end

  test "should not save category without name" do
    category = pages(:one).categories.new
    assert_not category.save, "Saved the category without a name"
  end

  test "should not save category without blog" do
    category = Category.new(name: "This is a test category")
    assert_not category.save, "Saved the category without a blog"
  end

  test "should not save category with duplicate name" do
    category = pages(:one).categories.new(name: "This is a test category")
    assert category.save
    category = pages(:one).categories.new(name: "This is a test category")
    assert_not category.save, "Saved the category with a duplicate name"
  end

  test "should generate slug on creation" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    category.save
    assert_not_nil category.slug, "Did not generate slug"
    assert_equal title.parameterize, category.slug, "Did not generate correct slug"
  end

  test "should generate slug on update" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    category.save
    new_name = "This is an updated test category"
    category.update(name: new_name)
    assert_not_nil category.slug, "Did not generate slug"
    assert_equal new_name.parameterize, category.slug, "Did not generate correct slug"
  end

  test "should not save category with existing slug" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    category.save
    category2 = pages(:one).categories.new(name: "This is an updated test category")
    assert category2.save
    category2.update(name: title)
    assert_not category2.save, "Saved the category with an existing slug"
  end

  test "should not save existing slug" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    category.save
    category2 = pages(:one).categories.new(name: title)
    assert_not category2.save, "Saved the category with an existing slug"
  end

  test "should not update slug to existing slug" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    category.save
    category2 = pages(:one).categories.new(name: "This is an updated test category")
    category2.save
    category2.update(name: title)
    assert_not category2.save, "Saved the category with an existing slug"
  end

  test "should not save category with duplicate name and parent" do
    category = pages(:one).categories.new(name: "This is a test category")
    assert category.save
    category2 = pages(:one).categories.new(name: "This is a test category 1", parent: category)
    category2.save
    category3 = pages(:one).categories.new(name: "This is a test category 1", parent: category)
    assert_not category3.save, "Saved the category with a duplicate name and parent"
  end

  test "should not save category with duplicate slug and null parent withing similar page_id" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    assert category.save
    category2 = pages(:one).categories.new(name: title)
    assert_not category2.save, "Saved the category with a duplicate slug and null parent within similar page_id"
  end

  test "should save same category within different page_id" do
    title = "This is a test category"
    category = pages(:one).categories.new(name: title)
    assert category.save
    category2 = pages(:two).categories.new(name: title)
    assert category2.save, category2.errors.full_messages
  end

  test "should not generate slug if send over params" do
    title = "new slug test 4"
    initial_slug = "test-slug-1"
    category = pages(:one).categories.new(name: title, slug: initial_slug)
    assert_equal category.slug, initial_slug
    category.save

    updated_slug = "test-slug-2"
    new_name = "This is an updated test category"
    category.update(name: new_name, slug: updated_slug)
    assert_not_nil category.slug, "Did not generate slug"
    assert_equal category.slug,  updated_slug
  end

  test "should remove attached image when image_url is changed" do
    category = pages(:one).categories.new(name: "This is a test category")
    category.image.attach(io: File.open(Rails.root.join('test', 'fixtures', 'files', 'alex.jpg')), filename: 'alex.jpg')
    category.save

    assert category.image.attached?

    category.image_url = "https://example.com/new_image.jpg"
    category.save

    assert_not category.image.attached?
    assert category.image_url == "https://example.com/new_image.jpg"
  end

  test "should clean image_url if new image is attached" do
    category = pages(:one).categories.new(name: "This is a test category", image_url: "https://example.com/new_image.jpg")
    category.save

    category.image.attach(io: File.open(Rails.root.join('test', 'fixtures', 'files', 'alex.jpg')), filename: 'alex.jpg')
    category.save

    assert_not category.image_url.present?
    assert category.image.attached?
  end
end
