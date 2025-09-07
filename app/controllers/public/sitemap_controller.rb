class Public::SitemapController < Public::PageApplicationController
  def index
    @host = @page.base_domain.presence || request.host
    @posts = @page.posts.published
    @categories = @page.categories
    @authors = @page.authors
    @last_post_updated_at = @posts.maximum(:updated_at)

    render "public/#{@page_settings.template}/sitemap/index", formats: :xml
  end
end
