class API::Internal::Pages::CategoriesController < API::Internal::Pages::ApplicationController

  def index
    @categories = @page.categories
    render json: @categories
  end

  def create
    @category = @page.categories.new(category_params)
    if @category.save
      render json: @category, status: :created
    else
      render json: @category.errors, status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.permit(:name, :description, :parent_id, :color, :og_image)
  end
end
