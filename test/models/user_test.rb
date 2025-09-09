require_relative "../test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user with invalid email" do
    user = User.create(email: "invalid email", password: "Secret 1*3*5*")
    assert_not user.save
  end

  test "should create a workspace when user is created" do
    user = User.create(email: "create_workspace@example.com", password: "Secret 1*3*5*")
    assert_not_nil user.workspaces.first
  end

  test "should make a user an owner of a created workspace" do
    user = User.create(email: "create_workspace_2@example.com", password: "Secret 1*3*5*")
    assert user.workspaces.first.owner?(user)
  end

  test "should save user with first_name and last_name if present" do
    user = User.create(email: "with_name@example.com", password: "Secret 1*3*5*")
    assert user.save
  end

  test "should not save user with first_name or last_name longer than 25 characters" do
    long_first_name = User.create(email: "with_name@example.com", password: "Secret 1*3*5*", first_name: "Abcdefghijklmnopqrstuvwxyz", last_name: "Doe")
    assert_not long_first_name.save, "Saved user with first_name longer than 25 characters"

    long_last_name = User.create(email: "with_name@example.com", password: "Secret 1*3*5*", first_name: "John", last_name: "Abcdefghijklmnopqrstuvwxyz")
    assert_not long_last_name.save, "Saved user with last_name longer than 25 characters"
  end

  # TODO: PRO NAME FORMATTING
  test "should return correct formatted name (w/o names)" do
    user = users(:lazaro_nixon)
    assert_equal "lazaronixon@hotmail.com", user.formatted_name
  end

  test "should return correct formatted name (w/ names)" do
    user = users(:alex_gonzalez)
    assert_equal "Alex Gonzalez", user.formatted_name
  end

  test "should create a page in workspace with default post when user is created" do
    user = User.create(email: "create_post@example.com", password: "Secret 1*3*5*")

    workspace = user.workspaces.first
    assert_not_nil workspace
    assert_not_nil workspace.pages.first

    post = workspace.pages.first.posts.first
    assert_not_nil post
    assert post.title, "Welcome to Your New Blog! ✨"
    assert post.status, :published
  end
end
