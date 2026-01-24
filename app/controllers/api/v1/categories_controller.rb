module API
  module V1
    class CategoriesController < BaseController
      before_action :set_page
      before_action :set_category, only: [:show, :update, :destroy]

      def_param_group :category_output do
        property :id, Integer, desc: "Category ID"
        property :name, String, desc: "Category name"
        property :slug, String, desc: "Category slug"
        property :description, String, desc: "Category description"
        property :color, String, desc: "Category color"
        property :parent_id, Integer, desc: "Parent category ID"
        property :page_id, Integer, desc: "Page ID"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/pages/:page_id/categories', "List all categories for a page"
      param :page_id, :number, required: true, desc: "Page ID"
      param_group :pagination
      returns code: 200, desc: "Paginated list of categories"
      def index
        render_collection(@page.categories.order(created_at: :desc)) { |category| category_json(category) }
      end

      api :GET, '/pages/:page_id/categories/:id', "Get a specific category"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Category ID"
      returns code: 200, desc: "Category details" do
        param_group :category_output
      end
      def show
        render_resource(@category) { |category| category_json(category) }
      end

      api :POST, '/pages/:page_id/categories', "Create a new category"
      param :page_id, :number, required: true, desc: "Page ID"
      param :category, Hash, desc: "Category info", required: true do
        param :name, String, desc: "Category name", required: true
        param :slug, String, desc: "Category slug"
        param :description, String, desc: "Category description"
        param :color, String, desc: "Category color (hex)"
        param :parent_id, :number, desc: "Parent category ID"
      end
      returns code: 201, desc: "Created category" do
        param_group :category_output
      end
      def create
        @category = @page.categories.new(category_params)
        if @category.save
          render_resource(@category, status: :created) { |category| category_json(category) }
        else
          render_error(@category.errors)
        end
      end

      api :PATCH, '/pages/:page_id/categories/:id', "Update a category"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Category ID"
      param :category, Hash, desc: "Category info", required: true do
        param :name, String, desc: "Category name"
        param :slug, String, desc: "Category slug"
        param :description, String, desc: "Category description"
        param :color, String, desc: "Category color (hex)"
        param :parent_id, :number, desc: "Parent category ID"
      end
      returns code: 200, desc: "Updated category" do
        param_group :category_output
      end
      def update
        if @category.update(category_params)
          render_resource(@category) { |category| category_json(category) }
        else
          render_error(@category.errors)
        end
      end

      api :DELETE, '/pages/:page_id/categories/:id', "Delete a category"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Category ID"
      returns code: 204, desc: "Category deleted"
      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_page
        @page = @current_workspace.pages.find(params[:page_id])
      end

      def set_category
        @category = @page.categories.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :slug, :description, :color, :parent_id)
      end

      def category_json(category)
        {
          id: category.id,
          name: category.name,
          slug: category.slug,
          description: category.description,
          color: category.color,
          parent_id: category.parent_id,
          page_id: category.page_id,
          created_at: category.created_at,
          updated_at: category.updated_at
        }
      end
    end
  end
end
