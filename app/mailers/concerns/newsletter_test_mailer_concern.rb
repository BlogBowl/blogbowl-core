module NewsletterTestMailerConcern
  extend ActiveSupport::Concern

  included do

  end

  def send_test_email(email, newsletter_settings, email_address)
    @email = email
    @settings = newsletter_settings

    mail(
      to: email_address,
      subject: "[TEST E-MAIL] #{email.subject}"
    )
  end

end