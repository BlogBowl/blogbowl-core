require_relative "../../../test_helper"

class API::Public::PostmarkControllerTest < ActionDispatch::IntegrationTest

  setup do
    @workspace = workspaces(:workspace_with_subscribers)
    @newsletter = newsletters(:newsletter_with_subscribers)
    @api_key = ENV.fetch('POSTMARK_X_API_KEY', Rails.application.credentials[Rails.env.to_sym][:postmark][:x_api_key])
    @city = "Novi Sad"
    @country = "Serbia"
  end

  test "should return unauthorized" do
    post api_public_postmark_event_url, params: {}

    assert_response :unauthorized
  end

  test "should return bad request if missing params" do
    post api_public_postmark_event_url,
         params: {},
         headers: { 'X-Api-Key': @api_key }

    assert_response :bad_request
  end

  test "should find and suppress subscriber" do
    verified_subscriber_1 = subscribers(:verified_1)

    assert_equal verified_subscriber_1.active, true
    assert_equal verified_subscriber_1.status, "active"
    assert_nil verified_subscriber_1.suppressed_at

    post api_public_postmark_event_url,
         params: get_subscription_change_params(@newsletter.postmark_server_id, verified_subscriber_1.email),
         headers: { 'X-Api-Key': @api_key }

    assert_response :success

    assert_enqueued_jobs 1

    perform_enqueued_jobs

    found_subscriber = Subscriber.find_by(email: verified_subscriber_1.email)
    assert_equal found_subscriber.active, false
    assert_equal found_subscriber.status, "suppressed"
    assert_not_nil found_subscriber.suppressed_at
  end

  test "should find and resubscribe subscriber" do
    verified_subscriber_2 = subscribers(:verified_2)

    verified_subscriber_2.suppress("ManualSuppression")

    post api_public_postmark_event_url,
         params: get_subscription_change_params(@newsletter.postmark_server_id, verified_subscriber_2.email, false),
         headers: { 'X-Api-Key': @api_key }

    assert_response :success

    assert_enqueued_jobs 1

    perform_enqueued_jobs

    found_subscriber = Subscriber.find_by(email: verified_subscriber_2.email)
    assert_equal found_subscriber.active, true
    assert_equal found_subscriber.status, "active"
    assert_nil found_subscriber.suppressed_at
  end

  test "should increase deliver count of each subscriber and newsletter email" do
    sent_newsletter_email = newsletter_emails(:sent_email_one)

    random_number = rand(5..25)

    random_number.times do |i|
      new_subscriber = @newsletter.subscribers.create!(email: "test_email_#{i}@test.com", verified: true, active: true, status: 'active', newsletter: @newsletter)

      post api_public_postmark_event_url,
           params: get_delivery_event_params(new_subscriber.email, sent_newsletter_email.postmark_tag),
           headers: { 'X-Api-Key': @api_key }

      assert_response :success
    end

    assert_enqueued_jobs random_number

    perform_enqueued_jobs

    random_number.times do |i|
      subscriber = @newsletter.subscribers.find_by(email: "test_email_#{i}@test.com")

      assert_not_nil subscriber
      assert_equal subscriber.deliver_count, 1
    end

    sent_newsletter_email = sent_newsletter_email.reload

    assert_equal sent_newsletter_email.deliver_count, random_number
  end

  test "should increase bounce count of each subscriber and newsletter email" do
    sent_newsletter_email = newsletter_emails(:sent_email_one)

    random_number = rand(5..25)

    random_number.times do |i|
      new_subscriber = @newsletter.subscribers.create!(email: "test_email_#{i}@test.com", verified: true, active: true, status: 'active', newsletter: @newsletter)

      post api_public_postmark_event_url,
           params: get_bounce_event_params(new_subscriber.email, sent_newsletter_email.postmark_tag),
           headers: { 'X-Api-Key': @api_key }

      assert_response :success
    end

    assert_enqueued_jobs random_number

    perform_enqueued_jobs

    random_number.times do |i|
      subscriber = @newsletter.subscribers.find_by(email: "test_email_#{i}@test.com")

      assert_not_nil subscriber
      assert_equal subscriber.bounce_count, 1
    end

    sent_newsletter_email = sent_newsletter_email.reload

    assert_equal sent_newsletter_email.bounce_count, random_number
  end

  test "should increase spam count of each subscriber and newsletter email" do
    sent_newsletter_email = newsletter_emails(:sent_email_one)

    random_number = rand(5..25)

    random_number.times do |i|
      new_subscriber = @newsletter.subscribers.create!(email: "test_email_#{i}@test.com", verified: true, active: true, status: 'active', newsletter: @newsletter)

      post api_public_postmark_event_url,
           params: get_spam_event_params(new_subscriber.email, sent_newsletter_email.postmark_tag),
           headers: { 'X-Api-Key': @api_key }

      assert_response :success
    end

    assert_enqueued_jobs random_number

    perform_enqueued_jobs

    random_number.times do |i|
      subscriber = @newsletter.subscribers.find_by(email: "test_email_#{i}@test.com")

      assert_not_nil subscriber
      assert_equal subscriber.spam_count, 1
    end

    sent_newsletter_email = sent_newsletter_email.reload

    assert_equal sent_newsletter_email.spam_count, random_number
  end

  test "should increase open count/set location of each subscriber and newsletter email" do
    sent_newsletter_email = newsletter_emails(:sent_email_one)

    random_number = rand(5..25)

    random_number.times do |i|
      new_subscriber = @newsletter.subscribers.create!(email: "test_email_#{i}@test.com", verified: true, active: true, status: 'active', newsletter: @newsletter)

      post api_public_postmark_event_url,
           params: get_open_event_params(new_subscriber.email, sent_newsletter_email.postmark_tag),
           headers: { 'X-Api-Key': @api_key }

      assert_response :success
    end

    assert_enqueued_jobs random_number

    perform_enqueued_jobs

    random_number.times do |i|
      subscriber = @newsletter.subscribers.find_by(email: "test_email_#{i}@test.com")

      assert_not_nil subscriber
      assert_equal subscriber.open_count, 1
      assert_equal subscriber.country, @country
      assert_equal subscriber.city, @city
    end

    sent_newsletter_email = sent_newsletter_email.reload

    assert_equal sent_newsletter_email.open_count, random_number
  end

  test "should increase click count/set location of each subscriber and newsletter email" do
    sent_newsletter_email = newsletter_emails(:sent_email_one)

    random_number = rand(5..25)

    random_number.times do |i|
      new_subscriber = @newsletter.subscribers.create!(email: "test_email_#{i}@test.com", verified: true, active: true, status: 'active', newsletter: @newsletter)

      post api_public_postmark_event_url,
           params: get_click_event_params(new_subscriber.email, sent_newsletter_email.postmark_tag),
           headers: { 'X-Api-Key': @api_key }

      assert_response :success
    end

    assert_enqueued_jobs random_number

    perform_enqueued_jobs

    random_number.times do |i|
      subscriber = @newsletter.subscribers.find_by(email: "test_email_#{i}@test.com")

      assert_not_nil subscriber
      assert_equal subscriber.click_count, 1
      assert_equal subscriber.country, @country
      assert_equal subscriber.city, @city
    end

    sent_newsletter_email = sent_newsletter_email.reload

    assert_equal sent_newsletter_email.click_count, random_number
  end


  private

  def get_subscription_change_params(postmark_server_id, email, suppress_sending = true)
    {
      "RecordType": "SubscriptionChange",
      "MessageID": "00000000-0000-0000-0000-000000000000",
      "ServerID": postmark_server_id,
      "MessageStream": "outbound",
      "ChangedAt": "2024-11-02T16:12:36Z",
      "Recipient": email,
      "Origin": "Recipient",
      "SuppressSending": suppress_sending,
      "SuppressionReason": "HardBounce",
      "Tag": "welcome-email",
      "Metadata": {
        "example": "value",
        "example_2": "value"
      }
    }
  end

  def get_delivery_event_params(email, postmark_tag)
    {
      "RecordType": "Delivery",
      "ServerID": 23,
      "MessageStream": "outbound",
      "MessageID": "00000000-0000-0000-0000-000000000000",
      "Recipient": email,
      "Tag": postmark_tag,
      "DeliveredAt": "2024-12-08T06:03:20Z",
      "Details": "Test delivery webhook details",
      "Metadata": {
        "example": "value",
        "example_2": "value"
      }
    }
  end

  def get_bounce_event_params(email, postmark_tag)
    {
      "ID": 42,
      "Type": "HardBounce",
      "RecordType": "Bounce",
      "TypeCode": 1,
      "Tag": postmark_tag,
      "MessageID": "00000000-0000-0000-0000-000000000000",
      "Details": "Test bounce details",
      "Email": email,
      "From": "sender@example.com",
      "BouncedAt": "2024-12-08T06:03:20Z",
      "Inactive": true,
      "DumpAvailable": true,
      "CanActivate": true,
      "Subject": "Test subject",
      "ServerID": 1234,
      "MessageStream": "outbound",
      "Content": "Test content",
      "Name": "Hard bounce",
      "Description": "The server was unable to deliver your message (ex: unknown user, mailbox not found).",
      "Metadata": {
        "example": "value",
        "example_2": "value"
      }
    }
  end

  def get_spam_event_params(email, postmark_tag)
    {
      "RecordType": "SpamComplaint",
      "ID": 42,
      "Type": "SpamComplaint",
      "TypeCode": 100001,
      "Tag": postmark_tag,
      "MessageID": "00000000-0000-0000-0000-000000000000",
      "Details": "Test spam complaint details",
      "Email": email,
      "From": "sender@example.com",
      "BouncedAt": "2024-12-08T06:03:20Z",
      "Inactive": true,
      "DumpAvailable": true,
      "CanActivate": true,
      "Subject": "Test subject",
      "ServerID": 1234,
      "MessageStream": "outbound",
      "Content": "Test content",
      "Name": "Spam complaint",
      "Description": "The subscriber explicitly marked this message as spam.",
      "Metadata": {
        "example": "value",
        "example_2": "value"
      }
    }
  end

  def get_open_event_params(email, postmark_tag)
    {
      "RecordType": "Open",
      "MessageStream": "outbound",
      "Metadata": {
        "example": "value",
        "example_2": "value"
      },
      "FirstOpen": true,
      "Recipient": email,
      "MessageID": "00000000-0000-0000-0000-000000000000",
      "ReceivedAt": "2024-12-08T06:03:20Z",
      "Platform": "WebMail",
      "ReadSeconds": 5,
      "Tag": postmark_tag,
      "UserAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
      "OS": {
        "Name": "OS X 10.7 Lion",
        "Family": "OS X 10",
        "Company": "Apple Computer, Inc."
      },
      "Client": {
        "Name": "Chrome 35.0.1916.153",
        "Family": "Chrome",
        "Company": "Google"
      },
      "Geo": {
        "IP": "188.2.95.4",
        "City": @city,
        "Country": @country,
        "CountryISOCode": "RS",
        "Region": "Autonomna Pokrajina Vojvodina",
        "RegionISOCode": "VO",
        "Zip": "21000",
        "Coords": "45.2517,19.8369"
      }
    }
  end

  def get_click_event_params(email, postmark_tag){
    "RecordType": "Click",
    "MessageStream": "outbound",
    "Metadata": {
      "example": "value",
      "example_2": "value"
    },
    "Recipient": email,
    "MessageID": "00000000-0000-0000-0000-000000000000",
    "ReceivedAt": "2024-12-08T06:03:20Z",
    "Platform": "Desktop",
    "ClickLocation": "HTML",
    "OriginalLink": "https://example.com",
    "Tag": postmark_tag,
    "UserAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
    "OS": {
      "Name": "OS X 10.7 Lion",
      "Family": "OS X 10",
      "Company": "Apple Computer, Inc."
    },
    "Client": {
      "Name": "Chrome 35.0.1916.153",
      "Family": "Chrome",
      "Company": "Google"
    },
    "Geo": {
      "IP": "188.2.95.4",
      "City": @city,
      "Country": @country,
      "CountryISOCode": "RS",
      "Region": "Autonomna Pokrajina Vojvodina",
      "RegionISOCode": "VO",
      "Zip": "21000",
      "Coords": "45.2517,19.8369"
    }
  }
  end

end
