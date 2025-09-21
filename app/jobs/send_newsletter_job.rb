require 'net/http'
require 'postmark'

class SendNewsletterJob < ApplicationJob

  queue_as :newsletter

  def perform(email_id, newsletter_id)
    newsletter = Newsletter.find(newsletter_id)
    newsletter_setting = newsletter.settings

    subscribers = newsletter.subscribers.active_and_verified.pluck(:email)

    postmark_server_token = newsletter.postmark_server_token

    postmark_client = Postmark::HttpClient.new(postmark_server_token)

    email = NewsletterEmail.find(email_id)

    payload = {
      From: newsletter_setting.sender_name.present? ? "#{newsletter_setting.sender_name} #{newsletter_setting.sender_email}" : newsletter_setting.sender_email,
      ReplyTo: newsletter_setting.reply_to_email,
      Subject: email.subject,
      HtmlBody: prepare_email_body(email, newsletter_setting),
      MessageStream: "broadcast",
      Tag: email.postmark_tag,
      Messages: subscribers.map { |subscriber| { To: subscriber } }
    }

    response = postmark_client.post('email/bulk', payload.to_json)

    id = response["Id"]
    email.update(postmark_bulk_id: id)
    email.mark_as_sent
  rescue => e
    email = NewsletterEmail.find(email_id)
    email.update(status: :failed)
    Rails.logger.error "Failed to send newsletter: #{e.message}"
    notify_exception(e, extra_context: { newsletter_id: newsletter_id, email_id: email_id, subscribers_count: subscribers.count })
  end

  private

  def prepare_email_body(email, newsletter_setting)
    ActionController::Base.render(
      template: 'layouts/newsletter',
      locals: {
        subject: email.subject,
        content: email.content_html,
        preview: email.preview,
        send_date: Date.today,
        author: email.author,
        footer: newsletter_setting.footer
      }
    )
  end

end
