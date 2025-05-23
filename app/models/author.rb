class Author < ApplicationRecord
  include AvatarHelper
  include Rails.application.routes.url_helpers
  include ConvertToWebp
  include AttachmentDeletable

  belongs_to :member

  has_many :post_authors, dependent: :destroy
  has_many :posts, through: :post_authors
  has_one :workspace, through: :member
  has_one :page, through: :workspace
  has_many :author_links, dependent: :destroy

  has_one_attached :avatar_picture do |attachable|
    attachable.variant :sm, resize_to_limit: [56, 56], format: :webp
    attachable.variant :md, resize_to_limit: [80, 80], format: :webp
    attachable.variant :lg, resize_to_limit: [256, 256], format: :webp
  end
  convert_to_webp_for :avatar_picture
  removable_attachment_for :avatar_picture

  has_one_attached :og_image
  convert_to_webp_for :og_image
  removable_attachment_for :og_image

  validates :avatar_picture, processable_file: true, size: { less_than: 5.megabytes, message: "is too large" }
  validates :og_image, processable_file: true, size: { less_than: 5.megabytes, message: "is too large" }

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :generate_slug

  validates :slug, presence: true
  validate :check_uniqueness_of_slug

  def formatted_name
    return email if first_name.blank? && last_name.blank?
    "#{first_name} #{last_name}"
  end

  def get_tag_description
    short_description.present? ? short_description : long_description
  end

  def avatar(size: 1, css_class: nil)
    return avatar_initials(size:, css_class:) unless avatar_picture.attached? && avatar_picture.attachment.blob.present? && avatar_picture.attachment.blob.persisted?
    avatar_pic(size:, picture: avatar_picture, css_class:)
  end

  def avatar_url
    return nil unless avatar_picture.attached?
    avatar_url_by_size(:md)
  end

  def as_json(options = nil)
    super.except(:created_at, :updated_at).merge(
      avatar: avatar_picture.attached? ? Rails.application.routes.url_helpers.rails_blob_url(avatar_picture, only_path: false) : nil,
      formatted_name: formatted_name
    )
  end

  def to_param
    slug
  end

  private

  def avatar_url_by_size(size)
    variant = avatar_picture.variant(size)
    rails_representation_url(variant, only_path: true)
  rescue StandardError
    nil
  end

  def avatar_initials(size: 1, css_class: nil)
    return avatar_placeholder(size:, initials: nil, css_class:) if email.blank?
    initials = email[0].upcase + email[1].upcase
    initials = [first_name, last_name].map { _1[0].upcase }.join if first_name.present? && last_name.present?

    avatar_placeholder(size:, initials:, css_class:)
  end

  def generate_slug
    if first_name.blank? and last_name.blank?
      # generate slug uuid
      self.slug = SecureRandom.uuid
    else
      slug = "#{first_name} #{last_name}".parameterize

      return if Author.joins(:member).where(slug: slug, members: { workspace_id: member.workspace_id })
                      .exists?

      self.slug = slug
    end
  end

  def check_uniqueness_of_slug
    if member&.workspace_id.present? &&
      Author.joins(:member)
            .where(members: { workspace_id: member.workspace_id }, slug: slug)
            .where.not(id: id) # Exclude the current author from the check
            .exists?
      errors.add(:slug, "must be unique within the workspace")
    end
  end
end
