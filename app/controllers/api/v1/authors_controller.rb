module API
  module V1
    class AuthorsController < BaseController
      before_action :set_author, only: [ :show, :update ]

      def_param_group :author_output do
        property :id, Integer, desc: "Author ID"
        property :first_name, String, desc: "First name"
        property :last_name, String, desc: "Last name"
        property :formatted_name, String, desc: "Formatted name"
        property :email, String, desc: "Author email"
        property :position, String, desc: "Author position"
        property :short_description, String, desc: "Short description"
        property :long_description, String, desc: "Long description"
        property :slug, String, desc: "Author slug"
        property :active, :boolean, desc: "Author active flag"
        property :avatar, String, desc: "Avatar URL"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number", default_value: 1
        param :size, :number, desc: "Items per page (max: 100)", default_value: 10
      end

      api :GET, "/authors", "List all authors for the workspace"
      param :active, :boolean, desc: "Filter by active flag (defaults to true)", default_value: true
      param_group :pagination
      returns code: 200, desc: "Paginated list of authors"
      def index
        authors = @current_workspace.authors.order(created_at: :desc)
        authors = if params.key?(:active)
          authors.where(active: ActiveModel::Type::Boolean.new.cast(params[:active]))
        else
          authors.where(active: true)
        end

        render_collection(authors) { |author| author_json(author) }
      end

      api :GET, "/authors/:id", "Get a specific author"
      param :id, :number, required: true, desc: "Author ID"
      returns code: 200, desc: "Author details" do
        param_group :author_output
      end
      def show
        render_resource(@author) { |author| author_json(author) }
      end

      api :PATCH, "/authors/:id", "Update an author"
      param :id, :number, required: true, desc: "Author ID"
      param :first_name, String, desc: "First name", default_value: nil
      param :last_name, String, desc: "Last name", default_value: nil
      param :position, String, desc: "Position", default_value: nil
      param :short_description, String, desc: "Short description", default_value: nil
      param :long_description, String, desc: "Long description", default_value: nil
      param :active, :boolean, desc: "Author active flag", default_value: nil
      param :avatar_picture, File, desc: "Avatar image", default_value: nil
      param :og_image, File, desc: "Open Graph image", default_value: nil
      returns code: 200, desc: "Updated author" do
        param_group :author_output
      end
      def update
        if @author.update(author_update_params)
          render_resource(@author) { |author| author_json(author) }
        else
          render_error(@author.errors)
        end
      end

      private

      def set_author
        @author = @current_workspace.authors.find(params[:id])
      end

      def author_update_params
        permit_resource_params(
          :author,
          :first_name, :last_name, :position, :short_description,
          :long_description, :active, :avatar_picture, :og_image
        )
      end

      def author_json(author)
        author.as_json.except("member_id").merge(
          short_description: author.short_description,
          long_description: author.long_description,
          created_at: author.created_at,
          updated_at: author.updated_at
        )
      end
    end
  end
end
