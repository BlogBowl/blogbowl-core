module TiptapContent
  extend ActiveSupport::Concern

  ALLOWED_HTML_TAGS = %w[
    p h1 h2 h3 h4 h5 h6 blockquote ul ol li
    strong em u s b i a code pre br hr
    img figure figcaption table thead tbody tr th td
    div iframe
  ].freeze

  ALLOWED_HTML_ATTRIBUTES = %w[
    href src alt title class id target rel colspan rowspan
    data-youtube-video data-type
    width height frameborder allowfullscreen allow
  ].freeze

  included do
    attr_accessor :content_md

    before_save :convert_markdown_to_html, if: :content_md_present?
    before_save :sanitize_content_html, if: :content_html_present?
    before_save :sync_content_formats, if: :should_sync_content?
  end

  private

  def content_md_present?
    content_md.present?
  end

  def content_html_present?
    content_html.present?
  end

  def convert_markdown_to_html
    self.content_html = TiptapConverter.md_to_html(content_md)
  rescue TiptapConverter::ConversionError => e
    Rails.logger.error("Markdown conversion failed: #{e.message}")
  end

  def sanitize_content_html
    self.content_html = ActionController::Base.helpers.sanitize(
      content_html,
      tags: ALLOWED_HTML_TAGS,
      attributes: ALLOWED_HTML_ATTRIBUTES
    )
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
