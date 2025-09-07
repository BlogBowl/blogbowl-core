# TODO: PRO
# app/controllers/concerns/newsletter_subscriber.rb
# module NewsletterSubscriber
#   extend ActiveSupport::Concern
#
#   private
#
#   def subscribe_user_to_newsletter(user)
#     return unless Rails.env.production?
#
#     Subscriber.find_or_create_by(email: user.email, newsletter_id: 2) do |subscriber|
#       subscriber.page_id = 1
#       subscriber.verified = true
#       subscriber.active = true
#       subscriber.status = 'active'
#       subscriber.verified_at = Time.current
#     end
#   end
# end
