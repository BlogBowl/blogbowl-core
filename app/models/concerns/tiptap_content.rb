module TiptapContent
  extend ActiveSupport::Concern

  included do
    before_save :sync_content_formats, if: :should_sync_content?
  end

  private

  def sync_content_formats
    if content_html_changed? && content_html.present? && content_json.blank?
      self.content_json = TiptapConverter.html_to_json(content_html)
    elsif content_json_changed? && content_json.present? && content_html.blank?
      self.content_html = TiptapConverter.json_to_html(content_json)
    end
  rescue TiptapConverter::ConversionError => e
    Rails.logger.error("TipTap conversion failed: #{e.message}")
  end

  def should_sync_content?
    (content_html_changed? || content_json_changed?) &&
      (content_html.present? || content_json.present?)
  end
end
