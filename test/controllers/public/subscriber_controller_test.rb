require_relative "../../test_helper"
require "minitest/mock"

class Public::SubscriberControllerTest < ActionDispatch::IntegrationTest
  include PublicHelper

  setup do
    @page = pages(:blog_with_domain_1)
    @page_settings = @page.settings
    @newsletter = @page_settings.newsletter
  end

  test "should create new subscriber and send email" do
    email = "newsubscriber@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    # Assertions
    subscriber = Subscriber.last
    assert_equal email, subscriber.email
    assert_equal @newsletter, subscriber.newsletter
    assert_equal 'pending', subscriber.status
    assert_not_nil subscriber.verification_token
    assert_not_nil subscriber.verification_email_sent_at

    assert_equal 'Please check your email to verify your subscription.', flash[:notice]
  end

  test "should not create new subscriber on 2nd try" do
    email = "newsubscriber2@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    subscriber = Subscriber.last
    assert_equal email, subscriber.email

    assert_no_difference 'Subscriber.count' do
      post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

      assert_response :success # Ensure that the response was successful
      assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
      assert_includes @response.body, '<dialog id="subscription_modal_dialog"'
    end
  end

  test "should not send email, if less than hour passed" do
    email = "newsubscriber@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 0
  end

  test "should send email, if less more than hour passed" do
    email = "newsubscriber@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    travel 1.5.hours

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email
  end

  test "should not send email, if already verified" do
    email = "newsubscriber3@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    subscriber = Subscriber.last
    subscriber.verify

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 0
  end

  test "should send email on resubscribe" do
    email = "newsubscriber4@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    subscriber = Subscriber.last
    subscriber.suppress("ManualSuppression")

    travel 1.5.hours

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    assert_equal verify_email.to.first, email
  end

  test "should block 6th request in one hour ( if creating multiple accounts )" do
    email = "newsubscriber5@blogbowl.io"

    3.times do |i|
      post "https://#{@page.domain}/subscribe",
           params: { subscriber: { email: "newsubscriber#{i + 3}@blogbowl.io" } },
           headers: { "REMOTE_ADDR" => "192.168.1.100" }

      assert_response :success # Ensure that the response was successful
      assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
      assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

      assert_equal "Please check your email to verify your subscription.", flash[:notice]
    end

    assert_enqueued_jobs 3

    post "https://#{@page.domain}/subscribe",
         params: { subscriber: { email: email } },
         headers: { "REMOTE_ADDR" => "192.168.1.100" }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, 'Too many requests!'

    assert_equal "Too many subscription attempts. Please try again later.", flash[:alert]
  end

  test "should block if comment passed (honeypot)" do
    email = "newsubscriber5@blogbowl.io"

    post "https://#{@page.domain}/subscribe",
         params: { subscriber: { email: email, comment: 'some spammy comment here' } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, 'Subscription failed!'
  end

  test "should verify subscriber" do
    email = "unverified_subscriber@blogbowl.io"

    post "https://#{@page.domain}/subscribe", params: { subscriber: { email: email } }

    assert_response :success # Ensure that the response was successful
    assert_includes @response.body, 'turbo-stream'  # Check if turbo-stream is included in the response
    assert_includes @response.body, '<dialog id="subscription_modal_dialog"'

    assert_enqueued_jobs 1

    perform_enqueued_jobs
    verify_email = ActionMailer::Base.deliveries.last

    assert_equal verify_email.to.first, email

    subscriber = Subscriber.last
    verification_url = get_full_url(dynamic_prefix("/subscribe/verify/#{subscriber.verification_token}"))

    get verification_url
    assert_redirected_to root_path

    subscriber = Subscriber.find_by(email: email)
    assert_equal 'active', subscriber.status
    assert_equal true, subscriber.verified
  end
end
