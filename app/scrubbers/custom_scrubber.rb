class CustomScrubber < Rails::Html::PermitScrubber
  def initialize
    super
    self.tags = %w(iframe p br b i u img a h1 h2 h3 h4 h5 h6 blockquote)
    self.attributes = %w(id class style src href data-width data-align)
  end

  # TODO: fix security
  def skip_node?(node)
    # node.name == "iframe"
    true
  end
end
