class Subscriber < ApplicationRecord
  belongs_to :newsletter
  belongs_to :page, optional: true

  validates :email, presence: true, uniqueness: { scope: :newsletter_id }, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :active_and_verified, -> { where(active: true, verified: true) }

  def verify
    update(status: 'active', verified: true, active: true, verified_at: Time.current, verification_token: nil, verification_email_sent_at: nil, suppression_reason: nil, suppressed_at: nil)
  end

  def suppress(suppression_reason)
    update(status: 'suppressed', active: false, suppressed_at: Time.current, suppression_reason: suppression_reason)
  end

  def click_rate
    return "N/A" if deliver_count.zero?

    percentage = (click_count.to_f / deliver_count * 100).round(2)
    "#{percentage} %"
  end

  def open_rate
    return "N/A" if deliver_count.zero?

    percentage = (open_count.to_f / deliver_count * 100).round(2)
    "#{percentage} %"
  end

  def location
    return "Unknown" if city.nil? || country.nil?
    "#{city}, #{country}"
  end

end
