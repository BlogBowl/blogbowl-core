module API
  module V1
    class PostsController < BaseController
      before_action :set_page
      before_action :set_post, only: [:show, :update, :destroy, :publish]

      def_param_group :post_output do
        property :id, Integer, desc: "Post ID"
        property :title, String, desc: "Post title"
        property :slug, String, desc: "Post slug"
        property :status, String, desc: "Post status (draft, published, scheduled)"
        property :description, String, desc: "Post description"
        property :content_html, String, desc: "Post content in HTML"
        property :content_json, Hash, desc: "Post content in TipTap JSON"
        property :seo_title, String, desc: "SEO title"
        property :seo_description, String, desc: "SEO description"
        property :og_title, String, desc: "Open Graph title"
        property :og_description, String, desc: "Open Graph description"
        property :category_id, Integer, desc: "Category ID"
        property :page_id, Integer, desc: "Page ID"
        property :scheduled_at, String, desc: "Scheduled publish date"
        property :first_published_at, String, desc: "First published date"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/pages/:page_id/posts', "List all posts for a page"
      param :page_id, :number, required: true, desc: "Page ID"
      param :status, String, desc: "Filter by status (draft, published, scheduled)"
      param :category_id, :number, desc: "Filter by category ID"
      param_group :pagination
      returns code: 200, desc: "Paginated list of posts"
      def index
        posts = @page.posts.order(created_at: :desc)
        posts = posts.where(status: params[:status]) if params[:status].present?
        posts = posts.where(category_id: params[:category_id]) if params[:category_id].present?
        render_collection(posts) { |post| post_json(post) }
      end

      api :GET, '/pages/:page_id/posts/:id', "Get a specific post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Post details" do
        param_group :post_output
      end
      def show
        render_resource(@post) { |post| post_json(post) }
      end

      api :POST, '/pages/:page_id/posts', "Create a new post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post, Hash, desc: "Post info", required: true do
        param :title, String, desc: "Post title", required: true
        param :content_html, String, desc: "Post content in HTML"
        param :content_json, Hash, desc: "Post content in TipTap JSON"
        param :description, String, desc: "Post description"
        param :category_id, :number, desc: "Category ID"
        param :seo_title, String, desc: "SEO title"
        param :seo_description, String, desc: "SEO description"
        param :og_title, String, desc: "Open Graph title"
        param :og_description, String, desc: "Open Graph description"
      end
      returns code: 201, desc: "Created post" do
        param_group :post_output
      end
      def create
        @post = @page.posts.new(post_params)
        if @post.save
          render_resource(@post, status: :created) { |post| post_json(post) }
        else
          render_error(@post.errors)
        end
      end

      api :PATCH, '/pages/:page_id/posts/:id', "Update a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      param :post, Hash, desc: "Post info", required: true do
        param :title, String, desc: "Post title"
        param :content_html, String, desc: "Post content in HTML"
        param :content_json, Hash, desc: "Post content in TipTap JSON"
        param :description, String, desc: "Post description"
        param :category_id, :number, desc: "Category ID"
        param :seo_title, String, desc: "SEO title"
        param :seo_description, String, desc: "SEO description"
        param :og_title, String, desc: "Open Graph title"
        param :og_description, String, desc: "Open Graph description"
      end
      returns code: 200, desc: "Updated post" do
        param_group :post_output
      end
      def update
        if @post.update(post_params)
          render_resource(@post) { |post| post_json(post) }
        else
          render_error(@post.errors)
        end
      end

      api :DELETE, '/pages/:page_id/posts/:id', "Delete a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      returns code: 204, desc: "Post deleted"
      def destroy
        @post.destroy
        head :no_content
      end

      api :POST, '/pages/:page_id/posts/:id/publish', "Publish a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      param :scheduled_at, String, desc: "Schedule publish for a future date (ISO 8601)"
      returns code: 200, desc: "Published/scheduled post" do
        param_group :post_output
      end
      def publish
        # Already published - return current state (idempotent)
        if @post.published?
          render_resource(@post) { |post| post_json(post) }
          return
        end

        if params[:scheduled_at].present?
          scheduled_time = Time.parse(params[:scheduled_at]).utc

          if scheduled_time.past?
            render_error_message("Schedule date must be in the future")
            return
          end

          @post.update(scheduled_at: params[:scheduled_at], status: :scheduled)
          job = PublishPostJob.set(wait_until: scheduled_time).perform_later(@post.id)
          @post.update(job_id: job.job_id)
        else
          @post.publish!
        end

        render_resource(@post) { |post| post_json(post) }
      end

      private

      def set_page
        @page = @current_workspace.pages.find(params[:page_id])
      end

      def set_post
        @post = @page.posts.find(params[:id])
      end

      def post_params
        params.require(:post).permit(
          :title, :content_html, :description, :category_id,
          :seo_title, :seo_description, :og_title, :og_description,
          content_json: {}
        )
      end

      def post_json(post)
        {
          id: post.id,
          title: post.title,
          slug: post.slug,
          status: post.status,
          description: post.description,
          content_html: post.content_html,
          content_json: post.content_json,
          seo_title: post.seo_title,
          seo_description: post.seo_description,
          og_title: post.og_title,
          og_description: post.og_description,
          category_id: post.category_id,
          page_id: post.page_id,
          scheduled_at: post.scheduled_at,
          first_published_at: post.first_published_at,
          created_at: post.created_at,
          updated_at: post.updated_at
        }
      end
    end
  end
end
