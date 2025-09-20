module Models::NewsletterEmailConcern
  extend ActiveSupport::Concern

  included do
    belongs_to :newsletter

    before_validation :generate_slug, if: :should_generate_slug?
    validates :slug, presence: true, uniqueness: { scope: :newsletter_id }

    has_many_attached :images

    belongs_to :author, optional: true

    enum :status, { draft: 'draft', scheduled: 'scheduled', sent: 'sent', failed: 'failed' }
  end

  def to_param
    slug
  end

  def as_json(options = nil)
    super(options)
      .except(:created_at, :updated_at, :postmark_tag, :postmark_bulk_id, :job_id)
      .merge(author: author.as_json)
      .merge(settings: newsletter.settings.as_json(only: [:sender_name, :sender_email, :footer]))
  end

  def mark_as_sent
    update(status: :sent, sent_at: Time.current)
  end

  def bounce_rate
    return "N/A" if deliver_count.zero?

    percentage = (bounce_count.to_f / deliver_count * 100).round(2)
    "#{percentage} %"
  end

  def open_rate
    return "N/A" if deliver_count.zero?

    percentage = (open_count.to_f / deliver_count * 100).round(2)
    "#{percentage} %"
  end

  private

  def should_generate_slug?
    subject_changed? || new_record?
  end

  def generate_slug
    base_slug = subject.blank? ? "My subject" : subject.parameterize
    potential_slug = base_slug
    count = 1

    while NewsletterEmail.exists?(slug: potential_slug, newsletter_id: newsletter_id)
      potential_slug = "#{base_slug}-#{count}"
      count += 1
    end

    self.slug = potential_slug
  end
end