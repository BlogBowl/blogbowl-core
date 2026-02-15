module API
  module V1
    class RevisionsController < BaseController
      before_action :set_page
      before_action :set_post

      def_param_group :revision_output do
        property :id, Integer, desc: "Revision ID"
        property :post_id, Integer, desc: "Post ID"
        property :title, String, desc: "Revision title"
        property :content_html, String, desc: "Content in HTML"
        property :content_json, Hash, desc: "Content in TipTap JSON"
        property :seo_title, String, desc: "SEO title"
        property :seo_description, String, desc: "SEO description"
        property :og_title, String, desc: "Open Graph title"
        property :og_description, String, desc: "Open Graph description"
        property :share_id, String, desc: "Share ID for preview URL"
        property :shared_at, String, desc: "Share creation date"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      api :GET, '/pages/:page_id/posts/:post_id/revisions', "List revisions for a post (last 20)"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "List of revisions"
      def index
        revisions = @post.post_revisions.order(updated_at: :desc).limit(20)
        render json: {
          page: 1,
          size: 20,
          total: @post.post_revisions.count,
          result: revisions.map { |revision| revision_json(revision) }
        }
      end

      api :POST, '/pages/:page_id/posts/:post_id/revisions', "Create a new revision"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :revision, Hash, desc: "Revision info" do
        param :title, String, desc: "Revision title"
        param :content_html, String, desc: "Content in HTML"
        param :content_json, Hash, desc: "Content in TipTap JSON"
        param :seo_title, String, desc: "SEO title"
        param :seo_description, String, desc: "SEO description"
        param :og_title, String, desc: "Open Graph title"
        param :og_description, String, desc: "Open Graph description"
      end
      returns code: 201, desc: "Created revision" do
        param_group :revision_output
      end
      def create
        revision = @post.new_revision

        if revision.update(revision_params)
          render_resource(revision, status: :created) { |r| revision_json(r) }
        else
          render_error(revision.errors)
        end
      end

      api :GET, '/pages/:page_id/posts/:post_id/revisions/last', "Get the last revision"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Last revision" do
        param_group :revision_output
      end
      def show_last
        revision = @post.post_revisions.last
        if revision.nil?
          render_error_message("Post revision not found", status: :not_found)
          return
        end
        render_resource(revision) { |r| revision_json(r) }
      end

      api :PATCH, '/pages/:page_id/posts/:post_id/revisions/last', "Update the last revision"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :revision, Hash, desc: "Revision info" do
        param :title, String, desc: "Revision title"
        param :content_html, String, desc: "Content in HTML"
        param :content_json, Hash, desc: "Content in TipTap JSON"
        param :seo_title, String, desc: "SEO title"
        param :seo_description, String, desc: "SEO description"
        param :og_title, String, desc: "Open Graph title"
        param :og_description, String, desc: "Open Graph description"
      end
      returns code: 200, desc: "Updated revision" do
        param_group :revision_output
      end
      def update_last
        revision = @post.post_revisions.last
        if revision.nil?
          render_error_message("Post does not have any revision", status: :conflict)
          return
        end

        if revision.update(revision_params)
          render_resource(revision) { |r| revision_json(r).merge(slug: @post.slug) }
        else
          render_error(revision.errors)
        end
      end

      api :POST, '/pages/:page_id/posts/:post_id/revisions/last/apply', "Apply the last revision to the post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Applied revision" do
        param_group :revision_output
      end
      def apply_last
        revision = @post.post_revisions.last
        if revision.nil?
          render_error_message("Post does not have any revision", status: :conflict)
          return
        end

        revision.apply!
        render_resource(revision) { |r| revision_json(r) }
      end

      api :POST, '/pages/:page_id/posts/:post_id/revisions/last/share', "Generate a share link for the last revision"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Revision with share ID" do
        param_group :revision_output
      end
      def share_last
        revision = @post.post_revisions.last
        if revision.nil?
          render_error_message("Post does not have any revision", status: :conflict)
          return
        end

        revision.share if revision.share_id.nil?
        render_resource(revision) { |r| revision_json(r) }
      end

      private

      def set_page
        @page = @current_workspace.pages.find(params[:page_id])
      end

      def set_post
        @post = @page.posts.find(params[:post_id])
      end

      def revision_params
        params.require(:revision).permit(
          :title, :content_html, :seo_title, :seo_description,
          :og_title, :og_description, content_json: {}
        )
      end

      def revision_json(revision)
        {
          id: revision.id,
          post_id: revision.post_id,
          title: revision.title,
          content_html: revision.content_html,
          content_json: revision.content_json,
          seo_title: revision.seo_title,
          seo_description: revision.seo_description,
          og_title: revision.og_title,
          og_description: revision.og_description,
          share_id: revision.share_id,
          shared_at: revision.shared_at,
          created_at: revision.created_at,
          updated_at: revision.updated_at
        }
      end
    end
  end
end
