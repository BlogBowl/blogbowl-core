module TiptapContent
  extend ActiveSupport::Concern

  included do
    attribute :content_md, :string

    before_save :convert_markdown_to_html, if: :content_md_present?
    before_save :sync_content_formats, if: :should_sync_content?
  end

  private

  def content_md_present?
    content_md.present?
  end

  def convert_markdown_to_html
    self.content_html = TiptapConverter.md_to_html(content_md)
  rescue TiptapConverter::ConversionError => e
    Rails.logger.error("Markdown conversion failed: #{e.message}")
  end

  def sync_content_formats
    if content_html_changed? && content_html.present?
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
