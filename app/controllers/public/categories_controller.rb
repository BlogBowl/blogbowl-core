class Public::CategoriesController < Public::PageApplicationController
  include Pagy::Backend

  before_action :set_category, only: [:show]

  def index
    @pagy, @categories = pagy(@page.categories, page: params[:page] || 1)
    render index_view
  end

  def show
    if @category.nil?
      render_not_found
      return
    end
    @pagy, @posts = pagy(@page.posts.published.where(category_id: @category.id), page: params[:page] || 1)
    render show_view
  end

  private

  def set_category
    @category = @page.categories.find_by(slug: params[:id])
  end

  def show_view
    "public/#{@page_settings.template}/categories/show"
  end

  def index_view
    "public/#{@page_settings.template}/categories/index"
  end
end
