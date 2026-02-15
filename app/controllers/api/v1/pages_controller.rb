module API
  module V1
    class PagesController < BaseController

      def_param_group :page_output do
        property :id, Integer, desc: "Page ID"
        property :name, String, desc: "Page name"
        property :slug, String, desc: "Page slug"
        property :name_slug, String, desc: "Page name slug"
        property :domain, String, desc: "Page domain"
        property :workspace_id, Integer, desc: "Workspace ID"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/pages', "List all pages for the workspace"
      param_group :pagination
      returns code: 200, desc: "Paginated list of pages"
      def index
        render_collection(@current_workspace.pages.order(created_at: :desc)) { |page| page_json(page) }
      end

      api :GET, '/pages/:id', "Get a specific page"
      param :id, :number, required: true, desc: "Page ID"
      returns code: 200, desc: "Page details" do
        param_group :page_output
      end
      def show
        @page = @current_workspace.pages.find(params[:id])
        render_resource(@page) { |page| page_json(page) }
      end

      api :POST, '/pages', "Create a new page"
      param :page, Hash, desc: "Page info", required: true do
        param :name, String, desc: "Page name", required: true
        param :slug, String, desc: "Page slug"
      end
      returns code: 201, desc: "Created page" do
        param_group :page_output
      end
      def create
        @page = @current_workspace.pages.new(page_params)
        if @page.save
          render_resource(@page, status: :created) { |page| page_json(page) }
        else
          render_error(@page.errors)
        end
      end

      api :PATCH, '/pages/:id', "Update a page"
      param :id, :number, required: true, desc: "Page ID"
      param :page, Hash, desc: "Page info", required: true do
        param :name, String, desc: "Page name"
        param :slug, String, desc: "Page slug"
      end
      returns code: 200, desc: "Updated page" do
        param_group :page_output
      end
      def update
        @page = @current_workspace.pages.find(params[:id])
        if @page.update(page_params)
          render_resource(@page) { |page| page_json(page) }
        else
          render_error(@page.errors)
        end
      end

      private

      def page_params
        params.require(:page).permit(:name, :slug)
      end

      def page_json(page)
        {
          id: page.id,
          name: page.name,
          slug: page.slug,
          name_slug: page.name_slug,
          domain: page.domain,
          workspace_id: page.workspace_id,
          created_at: page.created_at,
          updated_at: page.updated_at
        }
      end
    end
  end
end