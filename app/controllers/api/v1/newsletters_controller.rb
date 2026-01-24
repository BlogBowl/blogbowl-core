module API
  module V1
    class NewslettersController < BaseController

      def_param_group :newsletter_output do
        property :id, Integer, desc: "Newsletter ID"
        property :name, String, desc: "Newsletter name"
        property :name_slug, String, desc: "Newsletter slug"
        property :workspace_id, Integer, desc: "Workspace ID"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/newsletters', "List all newsletters for the workspace"
      param_group :pagination
      returns code: 200, desc: "Paginated list of newsletters"
      def index
        render_collection(@current_workspace.newsletters.order(created_at: :desc)) { |newsletter| newsletter_json(newsletter) }
      end

      api :GET, '/newsletters/:id', "Get a specific newsletter"
      param :id, :number, required: true, desc: "Newsletter ID"
      returns code: 200, desc: "Newsletter details" do
        param_group :newsletter_output
      end
      def show
        @newsletter = @current_workspace.newsletters.find(params[:id])
        render_resource(@newsletter) { |newsletter| newsletter_json(newsletter) }
      end

      api :POST, '/newsletters', "Create a new newsletter"
      param :newsletter, Hash, desc: "Newsletter info", required: true do
        param :name, String, desc: "Newsletter name", required: true
      end
      returns code: 201, desc: "Created newsletter" do
        param_group :newsletter_output
      end
      def create
        @newsletter = @current_workspace.newsletters.new(newsletter_params)
        if @newsletter.save
          render_resource(@newsletter, status: :created) { |newsletter| newsletter_json(newsletter) }
        else
          render_error(@newsletter.errors)
        end
      end

      api :PATCH, '/newsletters/:id', "Update a newsletter"
      param :id, :number, required: true, desc: "Newsletter ID"
      param :newsletter, Hash, desc: "Newsletter info", required: true do
        param :name, String, desc: "Newsletter name"
      end
      returns code: 200, desc: "Updated newsletter" do
        param_group :newsletter_output
      end
      def update
        @newsletter = @current_workspace.newsletters.find(params[:id])
        if @newsletter.update(newsletter_params)
          render_resource(@newsletter) { |newsletter| newsletter_json(newsletter) }
        else
          render_error(@newsletter.errors)
        end
      end

      private

      def newsletter_params
        params.require(:newsletter).permit(:name)
      end

      def newsletter_json(newsletter)
        {
          id: newsletter.id,
          name: newsletter.name,
          name_slug: newsletter.name_slug,
          workspace_id: newsletter.workspace_id,
          created_at: newsletter.created_at,
          updated_at: newsletter.updated_at
        }
      end
    end
  end
end
