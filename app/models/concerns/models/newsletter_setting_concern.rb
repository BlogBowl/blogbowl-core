module Models::NewsletterSettingConcern
  extend ActiveSupport::Concern

  included do
    include AttachmentDeletable

    belongs_to :newsletter
    accepts_nested_attributes_for :newsletter, update_only: true

    has_one_attached :logo do |attachable|
      attachable.variant :email, resize_to_limit: [140, 45], format: :png, preprocessed: true
    end
    removable_attachment_for :logo

    before_validation :generate_sender_email
    validates :logo, processable_file: true, size: { less_than: 1.megabyte, message: 'is too large' }
  end

  def settings_filled
    domain.present? && sender_email.present?
  end

  private

  def generate_sender_email
    return if domain.blank? || sender.blank?

    self.sender_email = "#{sender}@#{domain}"
  end
end