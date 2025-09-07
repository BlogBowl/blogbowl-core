class ProcessPostmarkEventJob < ApplicationJob
  queue_as :postmark_webhooks

  retry_on StandardError, wait: :polynomially_longer, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  def perform(webhook_data)
    record_type = webhook_data["RecordType"]

    case record_type
    when "SubscriptionChange"
      subscription_change(webhook_data)
    when "Click"
      on_click(webhook_data)
    when "Open"
      on_open(webhook_data)
    when "Delivery"
      on_delivery(webhook_data)
    when "Bounce"
      on_bounce(webhook_data)
    when "SpamComplaint"
      on_spam(webhook_data)
    else
      # TODO: PRO
      # Sentry.capture_message("[Postmark] Webhook triggered - unknown record type", extra: params.as_json)
    end

  end

  private

  def subscription_change(webhook_data)
    if webhook_data["ServerID"].nil? or webhook_data["Recipient"].nil? or webhook_data["SuppressSending"].nil?
      # TODO: PRO
      # Sentry.capture_message("[Postmark] Subscription changed - some webhook_data does not exist", extra: webhook_data.as_json)
      return
    end

    newsletter = Newsletter.find_by(postmark_server_id: webhook_data["ServerID"])

    if newsletter.nil?
      return
    end

    found_subscriber = Subscriber.find_by(email: webhook_data["Recipient"], newsletter_id: newsletter.id)

    if found_subscriber.nil?
      return
    end

    suppress_sending = webhook_data["SuppressSending"]
    if suppress_sending
      found_subscriber.suppress(webhook_data["SuppressionReason"])
    else
      found_subscriber.verify
    end
  rescue => e
    # TODO: PRO
    # Sentry.capture_exception(e, extra: webhook_data.as_json)
    raise e
  end

  def on_click(webhook_data)
    event_increment(webhook_data, :click_count, "Click")
  end

  def on_open(webhook_data)
    event_increment(webhook_data, :open_count, "Open")
  end

  def on_delivery(webhook_data)
    event_increment(webhook_data, :deliver_count, "Deliver")
  end

  def on_bounce(webhook_data)
    event_increment(webhook_data, :bounce_count, "Bounce", "Email")
  end

  def on_spam(webhook_data)
    event_increment(webhook_data, :spam_count, "Spam Complaint", "Email")
  end

  def event_increment(webhook_data, counter, event, email_field = "Recipient")
    newsletter_email = NewsletterEmail.find_by(postmark_tag: webhook_data["Tag"])

    if newsletter_email.nil?
      # TODO: PRO
      # Sentry.capture_message("[#{event}] Newsletter email not found for tag: tag:#{webhook_data['Tag']}", extra: webhook_data.as_json)
      raise ActiveRecord::RecordNotFound, "[#{event}] Newsletter email not found for tag: tag:#{webhook_data['Tag']}"
    end

    newsletter_email.with_lock do
      newsletter_email.increment!(counter)
    end

    subscriber = Subscriber.find_by(email: webhook_data[email_field], newsletter_id: newsletter_email.newsletter.id)

    if subscriber.nil?
      # TODO: PRO
      # Sentry.capture_message("[#{event}] Subscriber not found recipient:#{webhook_data[email_field]} NewsletterID:#{newsletter_email.newsletter.id}", extra: webhook_data.as_json)
      raise ActiveRecord::RecordNotFound, "[#{event}] Subscriber not found recipient:#{webhook_data[email_field]} NewsletterID:#{newsletter_email.newsletter.id}"
    end

    subscriber.with_lock do
      subscriber.increment!(counter)
      if subscriber.country.nil? and webhook_data["Geo"].present?
        subscriber.update(country: webhook_data["Geo"]["Country"], city: webhook_data["Geo"]["City"])
      end
    end

  end

end