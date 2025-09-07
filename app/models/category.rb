class Category < ApplicationRecord
  include ConvertToWebp
  include AttachmentDeletable

  belongs_to :parent, class_name: 'Category', optional: true
  belongs_to :page, optional: false

  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :posts
  has_many :page_topics, dependent: :nullify

  has_one_attached :image
  convert_to_webp_for :image
  removable_attachment_for :image

  has_one_attached :og_image
  convert_to_webp_for :og_image
  removable_attachment_for :og_image

  before_validation :generate_slug
  before_update :keep_single_image

  validates :name, presence: true, uniqueness: { scope: [:page_id, :parent_id] }
  validates :slug, presence: true, uniqueness: { scope: [:page_id, :parent_id] }

  validates :image, processable_file: true, size: { less_than: 5.megabytes, message: 'is too large' }
  validates :og_image, processable_file: true, size: { less_than: 5.megabytes, message: 'is too large' }

  def to_param
    slug
  end

  private

  def keep_single_image
    image.purge and return if image.attached? && image_url_changed?
    self.image_url = nil if image_url.present? && image.changed?
  end

  def generate_slug
    return if name.blank?

    return if slug_changed?

    new_slug = name.parameterize

    return if Category.exists?(slug: new_slug, page_id: page_id)

    self.slug = new_slug
  end
end
