module API
  module V1
    class ImagesController < BaseController
      before_action :set_page
      before_action :set_post

      # --- Cover Image Endpoints ---

      api :GET, "/pages/:page_id/posts/:post_id/cover_image", "Get the cover image for a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 200, desc: "Cover image URL"
      def show
        if @post.cover_image.attached?
          render json: { url: url_for(@post.cover_image) }
        else
          render_error_message("No cover image attached", status: :not_found)
        end
      end

      api :POST, "/pages/:page_id/posts/:post_id/cover_image", "Upload a cover image for a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :file, File, required: true, desc: "Image file to upload"
      returns code: 201, desc: "Uploaded cover image URL"
      def create
        unless params[:file].present?
          render_error_message("File is required")
          return
        end

        @post.cover_image.attach(params[:file])

        if @post.cover_image.attached?
          render json: { url: url_for(@post.cover_image) }, status: :created
        else
          render_error_message("Failed to save cover image")
        end
      end

      api :PATCH, "/pages/:page_id/posts/:post_id/cover_image", "Replace the cover image for a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :file, File, required: true, desc: "Image file to upload"
      returns code: 200, desc: "Updated cover image URL"
      def update
        unless params[:file].present?
          render_error_message("File is required")
          return
        end

        @post.cover_image.attach(params[:file])

        if @post.cover_image.attached?
          render json: { url: url_for(@post.cover_image) }
        else
          render_error_message("Failed to save cover image")
        end
      end

      api :DELETE, "/pages/:page_id/posts/:post_id/cover_image", "Remove the cover image from a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      returns code: 204, desc: "Cover image removed"
      def destroy
        if @post.cover_image.attached?
          @post.cover_image.purge
          head :no_content
        else
          render_error_message("No cover image attached", status: :not_found)
        end
      end

      private

      def set_page
        @page = @current_workspace.pages.find(params[:page_id])
      end

      def set_post
        @post = @page.posts.find(params[:post_id])
      end
    end
  end
end
