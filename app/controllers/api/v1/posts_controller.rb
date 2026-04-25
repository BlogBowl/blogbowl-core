require "open-uri"

module API
  module V1
    class PostsController < BaseController
      before_action :set_page
      before_action :set_post, only: [ :show, :update, :destroy ]

      def_param_group :post_output do
        property :id, Integer, desc: "Post ID"
        property :title, String, desc: "Post title"
        property :slug, String, desc: "Post slug"
        property :status, String, desc: "Post status (draft, published, scheduled)"
        property :description, String, desc: "Post description"
        property :content_html, String, desc: "Post content in HTML"
        property :seo_title, String, desc: "SEO title"
        property :seo_description, String, desc: "SEO description"
        property :og_title, String, desc: "Open Graph title"
        property :og_description, String, desc: "Open Graph description"
        property :cover_image_url, String, desc: "Cover image URL"
        property :og_image_url, String, desc: "Open Graph image URL"
        property :category_id, Integer, desc: "Category ID"
        property :page_id, Integer, desc: "Page ID"
        property :scheduled_at, String, desc: "Scheduled publish date"
        property :first_published_at, String, desc: "First published date"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
        property :faq_answers, Array, desc: "FAQ entries (question/answer pairs)"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number", default_value: 1
        param :size, :number, desc: "Items per page (max: 100)", default_value: 10
      end

      api :GET, "/pages/:page_id/posts", "List all posts for a page"
      param :page_id, :number, required: true, desc: "Page ID"
      param :status, String, desc: "Filter by status (draft, published, scheduled)", default_value: nil
      param :category_id, :number, desc: "Filter by category ID", default_value: nil
      param_group :pagination
      returns code: 200, desc: "Paginated list of posts"
      def index
        posts = @page.posts.order(created_at: :desc)
        posts = posts.where(status: params[:status]) if params[:status].present?
        posts = posts.where(category_id: params[:category_id]) if params[:category_id].present?
        render_collection(posts) { |post| post_json(post) }
      end

      api :GET, "/pages/:page_id/posts/:id", "Get a specific post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Post details" do
        param_group :post_output
      end
      def show
        render_resource(@post) { |post| post_json(post) }
      end

      api :POST, "/pages/:page_id/posts", "Create a new post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :title, String, desc: "Post title", required: true
      param :status, String, desc: "Post status (draft, published)", default_value: "draft"
      param :content_html, String, desc: "Post content in HTML", default_value: nil
      param :content_md, String, desc: "Post content in Markdown", default_value: nil
      param :description, String, desc: "Post description", default_value: nil
      param :category_id, :number, desc: "Category ID", default_value: nil
      param :seo_title, String, desc: "SEO title", default_value: nil
      param :seo_description, String, desc: "SEO description", default_value: nil
      param :og_title, String, desc: "Open Graph title", default_value: nil
      param :og_description, String, desc: "Open Graph description", default_value: nil
      param :author_id, :number, desc: "Author ID", default_value: nil
      param :cover_image_url, String, desc: "Cover image URL", default_value: nil
      param :og_image_url, String, desc: "Open Graph image URL", default_value: nil
      param :faq_answers, Array, desc: "FAQ entries [{question, answer}]", default_value: nil
      returns code: 201, desc: "Created post" do
        param_group :post_output
      end
      def create
        @post = @page.posts.new(post_params)
        if @post.save
          assign_author(@post)
          attach_images_from_urls(@post)
          ensure_draft_revision(@post)
          @post.publish! if params[:status] == "published"
          render_resource(@post, status: :created) { |post| post_json(post) }
        else
          render_error(@post.errors)
        end
      end

      api :PATCH, "/pages/:page_id/posts/:id", "Update a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      param :title, String, desc: "Post title", default_value: nil
      param :status, String, desc: "Post status (draft, published)", default_value: nil
      param :content_html, String, desc: "Post content in HTML", default_value: nil
      param :content_md, String, desc: "Post content in Markdown", default_value: nil
      param :description, String, desc: "Post description", default_value: nil
      param :category_id, :number, desc: "Category ID", default_value: nil
      param :seo_title, String, desc: "SEO title", default_value: nil
      param :seo_description, String, desc: "SEO description", default_value: nil
      param :og_title, String, desc: "Open Graph title", default_value: nil
      param :og_description, String, desc: "Open Graph description", default_value: nil
      param :author_id, :number, desc: "Author ID", default_value: nil
      param :cover_image_url, String, desc: "Cover image URL", default_value: nil
      param :og_image_url, String, desc: "Open Graph image URL", default_value: nil
      param :faq_answers, Array, desc: "FAQ entries [{question, answer}]", default_value: nil
      returns code: 200, desc: "Updated post" do
        param_group :post_output
      end
      def update
        if @post.update(post_params)
          assign_author(@post)
          attach_images_from_urls(@post)
          create_revision_in_background(@post)
          @post.publish! if params[:status] == "published" && !@post.published?
          render_resource(@post) { |post| post_json(post) }
        else
          render_error(@post.errors)
        end
      end

      api :DELETE, "/pages/:page_id/posts/:id", "Delete a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :id, :number, required: true, desc: "Post ID"
      returns code: 204, desc: "Post deleted"
      def destroy
        @post.destroy
        head :no_content
      end

      private

      def set_page
        @page = @current_workspace.pages.find(params[:page_id])
      end

      def set_post
        @post = @page.posts.find(params[:id])
      end

      def post_params
        permit_resource_params(
          :post,
          :title, :content_html, :content_md, :description, :category_id,
          :seo_title, :seo_description, :og_title, :og_description,
          { faq_answers: [ :question, :answer ] }
        )
      end

      def assign_author(post)
        return unless params[:author_id].present?

        author = Author.find(params[:author_id])
        post.post_authors.where(role: :author).destroy_all
        post.post_authors.create!(author: author, role: :author)
      end

      def ensure_draft_revision(post)
        return if post.post_revisions.exists?

        revision = post.new_revision
        revision.title ||= post.title
        revision.save
      rescue => e
        Rails.logger.error("Failed to create initial revision for post #{post.id}: #{e.message}")
      end

      def create_revision_in_background(post)
        revision = post.new_revision
        revision.title ||= post.title
        revision.kind = :history
        revision.save
      rescue => e
        Rails.logger.error("Failed to create revision for post #{post.id}: #{e.message}")
      end

      def attach_images_from_urls(post)
        attach_image_from_url(post.cover_image, params[:cover_image_url]) if params[:cover_image_url].present?
        attach_image_from_url(post.sharing_image, params[:og_image_url]) if params[:og_image_url].present?
      end

      def attach_image_from_url(attachment, url)
        uri = URI.parse(url)
        filename = File.basename(uri.path).presence || "image"
        attachment.attach(io: uri.open, filename: filename)
      rescue => e
        Rails.logger.error("Failed to attach image from URL #{url}: #{e.message}")
      end

      def post_json(post)
        {
          id: post.id,
          title: post.title,
          slug: post.slug,
          status: post.status,
          description: post.description,
          content_html: post.content_html,
          seo_title: post.seo_title,
          seo_description: post.seo_description,
          og_title: post.og_title,
          og_description: post.og_description,
          cover_image_url: post.cover_image.attached? ? url_for(post.cover_image) : nil,
          og_image_url: post.sharing_image.attached? ? url_for(post.sharing_image) : nil,
          category_id: post.category_id,
          page_id: post.page_id,
          scheduled_at: post.scheduled_at,
          first_published_at: post.first_published_at,
          created_at: post.created_at,
          updated_at: post.updated_at,
          faq_answers: post.faq_answers
        }
      end
    end
  end
end
