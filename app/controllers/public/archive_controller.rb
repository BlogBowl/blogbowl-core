class Public::ArchiveController < Public::PageApplicationController
  include Pagy::Backend
  def show
    if params[:s].present?
      @search_query = params[:s].to_s.strip
      @pagy, @posts = pagy(@page.posts.published.where("title ILIKE ?", "%#{@search_query}%"), page: params[:page] || 1)
      render show_search_view
      return
    end
    @pagy, @posts = pagy(@page.posts.published, page: params[:page] || 1)
    render show_view
  end

  private

  def show_view
    "public/#{@page_settings.template}/archive/index"
  end

  def show_search_view
    "public/#{@page_settings.template}/search/show"
  end
end
