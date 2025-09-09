require_relative "../../test_helper"
require 'minitest/mock'
require 'ostruct' # Required for OpenStruct

class BillingControllerTest < ActionDispatch::IntegrationTest
  test "free user should see a button to upgrade" do
    sign_in_as(users(:free_user))
    get edit_settings_billing_url

    assert_select "input[type=submit][value='Continue to Checkout']"
  end

  test "paid user should see current workspace plan" do
    sign_in_as(users(:pro_user))

    mock_stripe_subscription = OpenStruct.new(id: 'cus_123456789', cancel_at_period_end: false, current_period_end: 1.month.from_now.to_i,)
    # Add other method expectations as needed

    # Mock the Stripe::Subscription.retrieve method
    Stripe::Subscription.stub :retrieve, mock_stripe_subscription do
      get edit_settings_billing_url
      assert_select "h2", "Current Workspace Plan"
    end
  end

  test "paid user should have a customer portal link" do
    sign_in_as(users(:pro_user))

    mock_stripe_subscription = OpenStruct.new(id: 'cus_123456789', cancel_at_period_end: false, current_period_end: 1.month.from_now.to_i,)
    # Add other method expectations as needed

    # Mock the Stripe::Subscription.retrieve method
    Stripe::Subscription.stub :retrieve, mock_stripe_subscription do
      get edit_settings_billing_url
      assert_select "a", "Manage Subscriptions"
    end
  end
end
