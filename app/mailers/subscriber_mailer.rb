class SubscriberMailer < ApplicationMailer
  def verification_email(subscriber, verification_url)
    @verification_url = verification_url
    @newsletter_settings = subscriber.newsletter.settings

    mail(
      to: subscriber.email,
      subject: "You're Almost In - Confirm Your Subscription"
    )
  end

end
