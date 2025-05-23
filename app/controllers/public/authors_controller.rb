class Public::AuthorsController < Public::PageApplicationController
  include Pagy::Backend

  before_action :set_author, only: [:show]

  def index
    @pagy, @authors = pagy(@page.authors, page: params[:page] || 1)
    render index_view
  end

  def show
    if @author.nil?
      render_not_found
    else
      render show_view
    end
  end

  private

  def set_author
    @author = @page.authors.find_by(slug: params[:id])
    @pagy, @posts = pagy(@page.posts.published, page: params[:page] || 1)
  end

  def show_view
    "public/#{@page_settings.template}/authors/show"
  end

  def index_view
    "public/#{@page_settings.template}/authors/index"
  end
end
