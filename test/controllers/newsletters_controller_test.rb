require_relative "../test_helper"

class NewslettersControllerTest < ActionDispatch::IntegrationTest

  # TODO: PRO
  # test "allow creating new pages on PRO plans" do
  #   sign_in_as(users(:pro_user))
  #
  #   workspace = workspaces(:pro_workspace)
  #
  #   assert workspace.newsletters.count, 1
  #
  #   assert_difference -> { workspace.newsletters.count }, 1 do
  #     post newsletters_path, params: { newsletter: { name: 'test' } }
  #   end
  # end
  #
  # test "disallow creating new pages on free plans" do
  #   sign_in_as(users(:free_user))
  #
  #   workspace = workspaces(:free_workspace)
  #
  #   assert workspace.newsletters.count, 1
  #
  #   post newsletters_path, params: { newsletter: { name: 'test' } }
  #   assert_response :unprocessable_entity
  #   assert_equal "To add new newsletter, please, upgrade to a paid plan!", flash[:alert]
  # end

end