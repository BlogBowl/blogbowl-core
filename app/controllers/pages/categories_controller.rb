class Pages::CategoriesController < Pages::ApplicationController
  include Pagy::Backend

  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @pagy, @categories = pagy(@page.categories, page: params[:page] || 1, limit: 20)
  end

  def edit
  end

  def new
    @category = @page.categories.build
  end

  def create
    @category = @page.categories.build(category_params)

    if @category.save
      flash[:notice] = 'Category was created successfully.'
      redirect_to pages_categories_path(@page)
    else
      flash.now[:alert] = @category.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      flash[:notice] = 'Category was updated successfully.'
      redirect_to pages_categories_path
    else
      flash.now[:alert] = @author.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      flash[:notice] = 'Category was deleted successfully.'
    else
      flash[:alert] = 'Failed to delete the category.'
    end
    redirect_to pages_categories_path
  end

  def set_category
    @category = @page.categories.find_by(slug: params[:id])
    render_not_found if @category.nil?
  end

  def category_params
    params.require(:category).permit(:name, :description, :slug, :color, :og_image, :remove_og_image, :image, :remove_image, :image_url)
  end
end
