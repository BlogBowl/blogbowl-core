module API
  module V1
    class AuthorsController < BaseController
      before_action :set_author, only: [ :show, :update, :destroy ]

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
      param :active, :boolean, desc: "Filter by active flag (defaults to true)"
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

      api :POST, "/authors", "Create (or reactivate) an author for current workspace member"
      param :first_name, String, desc: "First name"
      param :last_name, String, desc: "Last name"
      param :email, String, desc: "Author email"
      param :position, String, desc: "Position"
      param :short_description, String, desc: "Short description"
      param :long_description, String, desc: "Long description"
      param :avatar_picture, File, desc: "Avatar image"
      param :og_image, File, desc: "Open Graph image"
      returns code: 201, desc: "Created author" do
        param_group :author_output
      end
      def create
        member = @current_workspace.members.find_by!(user_id: @current_user.id)

        if member.author&.active?
          render_error_message("Author already exists for this member")
          return
        end

        author = member.author || member.build_author
        defaults = {
          email: member.user&.email,
          first_name: member.user&.email&.split("@")&.first
        }.compact

        attrs = defaults.merge(author_create_params).merge(active: true)

        if author.update(attrs)
          render_resource(author, status: :created) { |record| author_json(record) }
        else
          render_error(author.errors)
        end
      end

      api :PATCH, "/authors/:id", "Update an author"
      param :id, :number, required: true, desc: "Author ID"
      param :first_name, String, desc: "First name"
      param :last_name, String, desc: "Last name"
      param :email, String, desc: "Author email"
      param :position, String, desc: "Position"
      param :short_description, String, desc: "Short description"
      param :long_description, String, desc: "Long description"
      param :active, :boolean, desc: "Author active flag"
      param :avatar_picture, File, desc: "Avatar image"
      param :og_image, File, desc: "Open Graph image"
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

      api :DELETE, "/authors/:id", "Deactivate an author"
      param :id, :number, required: true, desc: "Author ID"
      returns code: 204, desc: "Author deactivated"
      def destroy
        if @author.update(active: false)
          head :no_content
        else
          render_error(@author.errors)
        end
      end

      private

      def set_author
        @author = @current_workspace.authors.find(params[:id])
      end

      def author_create_params
        permit_resource_params(
          :author,
          :first_name, :last_name, :email, :position,
          :short_description, :long_description, :avatar_picture, :og_image
        )
      end

      def author_update_params
        permit_resource_params(
          :author,
          :first_name, :last_name, :email, :position, :short_description,
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
