class SubscriberMailerPreview < ActionMailer::Preview
  include PublicHelper

  def verification_email
    workspace = Workspace.new(newsletter_setting: NewsletterSetting.new(sender_name: "BlogBowl", footer: "BlogBowl, Inc.\nCopyright 2025 LOL"))
    @page = Page.new(workspace:)
    subscriber = Subscriber.new(email: 'hello@blogbowl.io', workspace:)
    verification_url = get_full_url(dynamic_prefix("/subscribe/verify/#{subscriber.verification_token}"))
    SubscriberMailer.verification_email(subscriber, verification_url)
  end
end
