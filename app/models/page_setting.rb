class PageSetting < ApplicationRecord
  include AttachmentDeletable
  include ConvertToWebp

  belongs_to :page
  belongs_to :newsletter, optional: true
  accepts_nested_attributes_for :page, update_only: true

  has_one_attached :og_image
  removable_attachment_for :og_image
  convert_to_webp_for :og_image

  has_one_attached :logo
  removable_attachment_for :logo
  convert_to_webp_for :logo

  has_one_attached :favicon
  removable_attachment_for :favicon

  validates :og_image, processable_image: true, size: { less_than: 5.megabytes, message: 'is too large' }
  validates :logo, processable_image: true, size: { less_than: 5.megabytes, message: 'is too large' }
  validates :favicon, processable_image: true, size: { less_than: 512.kilobytes, message: 'is too large' }

  before_save :set_name

  def set_name
    self.name = logo_text.presence || title
  end

end
