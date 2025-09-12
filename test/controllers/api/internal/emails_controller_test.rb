require_relative "../../../test_helper"

class API::Internal::EmailsControllerTest < ActionDispatch::IntegrationTest

  test "should create email" do
    sign_in_as(users(:workspace_owner))

    newsletter = newsletters(:one)

    subject = "New test email"
    post api_internal_newsletters_emails_url(newsletter_id: newsletter.id), params: { subject: 'New test email' }, as: :json
    assert_response :created

    assert_not_nil newsletter.newsletter_emails.find_by(slug: subject.parameterize)
  end

  test "should update email" do
    sign_in_as(users(:workspace_owner))

    preview = "Email preview"
    email = newsletter_emails(:one)
    assert_not_equal email.preview, preview

    put api_internal_newsletters_email_url(newsletter_id: email.newsletter.id, id: email.id), params: { preview: preview }, as: :json
    assert_response :ok

    email.reload

    assert_equal email.preview, preview
  end

  test "should not update sent email" do
    sign_in_as(users(:workspace_owner))

    email = newsletter_emails(:one)
    email.mark_as_sent

    put api_internal_newsletters_email_path(newsletter_id: email.newsletter.id, id: email.id), params: { preview: "Test preview" }, as: :json
    assert_response :unprocessable_entity
  end

  test "should not send if active subscriber are empty" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)

    # Remove all subscribers
    newsletter.subscribers.destroy_all

    assert_equal newsletter.subscribers.active_and_verified.count, 0

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "No active and verified subscribers found", parsed_body["error"]
  end

  test "should not send if already sent" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)

    email.mark_as_sent

    assert_equal email.status, 'sent'
    assert_equal newsletter.subscribers.active_and_verified.count, 1

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Cannot send already sent email", parsed_body["error"]
  end

  test "should not send if content is empty" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)

    email.update(content_html: nil, content_json: nil)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Cannot send empty email", parsed_body["error"]
  end

  test "should not send if author is not set" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)
    email.update(author: nil)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Cannot send email without author", parsed_body["error"]
  end

  test "should not send email without subject" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)
    email.update(subject: nil)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Cannot send email without subject", parsed_body["error"]
  end

  test "should not send email if settings are not filled" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)
    newsletter.settings.update!(domain: nil, sender_email: nil)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Before sending e-mail, please, fill newsletter settings!", parsed_body["error"]
  end

  test "should send now if scheduled_at is not in params" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)
    email = newsletter_emails(:filled)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    stub_request(:post, "https://api.postmarkapp.com/email/bulk")
      .to_return(
        status: 200,
        body: { Id: 'mocked-bulk-id-12345' }.to_json, # The crucial part for your test
        headers: { 'Content-Type': 'application/json' }
      )

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json

    assert_response :ok

    email.reload
    assert_equal email.status, 'sent'
    assert_not_nil email.postmark_tag
    assert_not_nil email.postmark_bulk_id
    assert_equal 'mocked-bulk-id-12345', email.postmark_bulk_id
  end

  test "should be scheduled and processed at scheduled_at timestamp" do
    sign_in_as(users(:lazaro_nixon))

    newsletter = newsletters(:one)

    email = newsletter_emails(:filled)

    assert_equal newsletter.subscribers.active_and_verified.count, 1

    scheduled_at = Time.now + 5.hours

    stub_request(:post, "https://api.postmarkapp.com/email/bulk")
      .to_return(
        status: 200,
        body: { Id: 'mocked-bulk-id-12345' }.to_json, # The crucial part for your test
        headers: { 'Content-Type': 'application/json' }
      )

    post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: { scheduled_at: scheduled_at }, as: :json
    assert_response :ok

    assert_enqueued_jobs 1

    email.reload

    assert_equal email.status, 'scheduled'
    assert_not_nil email.postmark_tag

    travel_to scheduled_at

    perform_enqueued_jobs

    assert_enqueued_jobs 0

    email.reload

    assert_equal email.status, 'sent'
    assert_not_nil email.postmark_tag
    assert_not_nil email.postmark_bulk_id
    assert_equal 'mocked-bulk-id-12345', email.postmark_bulk_id
  end


  test "cannot unschedule not scheduled email" do
    sign_in_as(users(:lazaro_nixon))

    email = newsletter_emails(:filled)
    email.mark_as_sent

    post api_internal_newsletters_email_unschedule_url(newsletter_id: email.newsletter.id, email_id: email.id), params: nil, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Email should be scheduled for unscheduling", parsed_body["error"]
  end

  test "cannot unschedule if job id is nil" do
    sign_in_as(users(:lazaro_nixon))

    email = newsletter_emails(:filled)
    email.update(job_id: nil, status: :scheduled)

    post api_internal_newsletters_email_unschedule_url(newsletter_id: email.newsletter.id, email_id: email.id), params: nil, as: :json

    assert_response :unprocessable_entity
    parsed_body = JSON.parse(response.body)
    assert_equal "Email should have job id", parsed_body["error"]
  end

  # TODO: PRO
  # test "should send test email on Pro plans" do
  #   sign_in_as(users(:pro_user))
  #
  #   newsletter = newsletters(:pro_workspace_newsletter)
  #   email = newsletter_emails(:filled_pro_email)
  #
  #   post api_internal_newsletters_email_send_test_path(newsletter_id: newsletter.id, email_id: email.id), params: { emailAddress: 'test222@test.com' }, as: :json
  #
  #   assert_enqueued_jobs 1
  # end
  #
  # test "should send email on Pro plans" do
  #   sign_in_as(users(:pro_user))
  #
  #   newsletter = newsletters(:pro_workspace_newsletter)
  #   email = newsletter_emails(:filled_pro_email)
  #
  #   post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json
  #
  #   assert_response :ok
  # end
  #
  # test "should not send emails on free plans" do
  #   sign_in_as(users(:free_user))
  #
  #   newsletter = newsletters(:free_workspace_newsletter)
  #   email = newsletter_emails(:filled_free_email)
  #
  #   post api_internal_newsletters_email_send_url(newsletter_id: newsletter.id, email_id: email.id), params: {}, as: :json
  #
  #   assert_response :bad_request
  #   json_response = JSON.parse(response.body)
  #   assert_equal "Newsletter is not supported in free plans", json_response["error"]
  # end
  #
  # test "should not send test emails on free plans" do
  #   sign_in_as(users(:free_user))
  #
  #   newsletter = newsletters(:free_workspace_newsletter)
  #   email = newsletter_emails(:filled_free_email)
  #
  #   post api_internal_newsletters_email_send_test_path(newsletter_id: newsletter.id, email_id: email.id), params: { emailAddress: 'test222@test.com' }, as: :json
  #
  #   assert_response :bad_request
  #   json_response = JSON.parse(response.body)
  #   assert_equal "Newsletter is not supported in free plans", json_response["error"]
  # end
end
