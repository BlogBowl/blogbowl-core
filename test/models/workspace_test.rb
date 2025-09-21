require_relative "../test_helper"
require "minitest/mock"

class WorkspaceTest < ActiveSupport::TestCase
  test "should create blog after created" do
    workspace = Workspace.create!(title: "Test Workspace")
    assert_not_nil workspace.pages.find_by(slug: 'blog')
  end

  test "should not create default newsletter if Postmark is disabled" do
    FeatureGuard.stub(:enabled?, false) do
      workspace = Workspace.create!(title: "Test Workspace")

      assert_equal workspace.newsletters.count, 0
    end
  end

  test "should create default newsletter if Postmark is enabled" do
    FeatureGuard.stub(:enabled?, true) do
      workspace = Workspace.create!(title: "Test Workspace")

      assert_equal workspace.newsletters.count, 1
    end
  end
end
