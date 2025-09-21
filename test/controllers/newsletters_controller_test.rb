require_relative "../test_helper"
require "minitest/mock"

class NewslettersControllerTest < ActionDispatch::IntegrationTest

  test "should not create newsletter if Postmark ACCOUNT_TOKEN is not added" do
    sign_in_as(users(:lazaro_nixon))
    FeatureGuard.stub(:enabled?, false) do
      get new_newsletter_url
      assert_redirected_to newsletters_url
      assert_equal "To use newsletter features add Postmark Account Token to ENV.", flash[:alert]

      assert_no_difference "Newsletter.count" do
        post newsletters_path, params: { newsletter: { name: 'Test Newsletter' } }
      end
      assert_redirected_to newsletters_url
      assert_equal "To use newsletter features add Postmark Account Token to ENV.", flash[:alert]
    end
  end

  test "should create newsletter if Postmark ACCOUNT_TOKEN is added" do
    sign_in_as(users(:lazaro_nixon))
    FeatureGuard.stub(:enabled?, true) do
      get new_newsletter_url

      assert_difference "Newsletter.count", 1 do
        post newsletters_path, params: { newsletter: { name: 'test' } }
      end
      assert_redirected_to newsletters_newsletter_emails_path(newsletter_id: 'test')
    end
  end

  test "should show the disabled feature notice on the index page when Postmark is not configured" do
    sign_in_as(users(:lazaro_nixon))
    FeatureGuard.stub(:enabled?, false) do
      # Visit a page that renders the notice, like the index page
      get newsletters_path
      assert_response :success

      # Assert that the notice's title and message are in the HTML
      assert_select "h3", "Newsletter Feature is Disabled"
    end
  end

  test "should not show the disabled feature notice on the index page when Postmark is configured" do
    sign_in_as(users(:lazaro_nixon))
    FeatureGuard.stub(:enabled?, true) do
      # Visit a page that renders the notice, like the index page
      get newsletters_path
      assert_response :success

      # Assert that the notice's title and message are in the HTML
      assert_select "h3", { count: 0, text: "Newsletter Feature is Disabled" }
    end
  end
end