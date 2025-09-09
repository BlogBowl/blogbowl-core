require_relative "../test_helper"
require "minitest/mock"

class WorkspaceTest < ActiveSupport::TestCase
  test "should create blog after created" do
    workspace = Workspace.create!(title: "Test Workspace")
    assert_not_nil workspace.pages.find_by(slug: 'blog')
  end

  # TODO: PRO
  # test "should update stripe customer after title changed" do
  #   workspace = workspaces(:pro_workspace)
  #
  #   mock = Minitest::Mock.new
  #   mock.expect(:call, true, [workspace])
  #
  #   StripeService.stub(:update_customer, mock) do
  #     workspace.update!(title: "New Title")
  #   end
  #
  #   assert mock.verify
  # end
end
