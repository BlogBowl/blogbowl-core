module ConvertToWebp
  extend ActiveSupport::Concern

  CONTENT_TYPES = %w[image/bmp image/jpeg image/png image/tiff].freeze

  included do
    attr_accessor :skip_webp_conversion
  end

  module ClassMethods
    def convert_to_webp_for(attachment_name)
      after_commit -> { convert_attachment_to_webp(attachment_name) }, on: [:create, :update]

      define_method("#{attachment_name}_changed?") do
        instance_variable_get("@#{attachment_name}_changed")
      end

      define_method("#{attachment_name}=") do |attachable|
        instance_variable_set("@#{attachment_name}_changed", true)
        super(attachable)
      end
    end
  end

  private

  def convert_attachment_to_webp(attachment_name)
    return if skip_webp_conversion
    return unless public_send("#{attachment_name}_changed?")

    attachments = public_send(attachment_name)
    if attachments.respond_to?(:each)
      attachments.each { |attachment| process_single_attachment(attachment, attachment_name) }
    else
      process_single_attachment(attachments, attachment_name)
    end
  end

  def process_single_attachment(attachment, association_name)
    return if CONTENT_TYPES.exclude?(attachment.content_type)

    require "image_processing/vips"

    temp_file = Tempfile.new(['original', File.extname(attachment.filename.to_s)])
    temp_file.binmode
    temp_file.write(attachment.download)
    temp_file.rewind

    processed = ImageProcessing::Vips
                  .source(temp_file)
                  .convert("webp")
                  .call

    self.skip_webp_conversion = true

    filename = attachment.filename.base
    attachment.purge

    public_send(association_name).attach(
      io: File.open(processed.path, 'rb'),
      filename: "#{filename}.webp",
      content_type: "image/webp"
    )
  rescue => e
    Rails.logger.error "Failed to convert image to WebP for #{association_name}: #{e.message}"
  ensure
    self.skip_webp_conversion = false
    if temp_file
      temp_file.close
      temp_file.unlink
    end
    processed&.close! if processed.respond_to?(:close!)
  end
end
