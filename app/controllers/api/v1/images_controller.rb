module API
  module V1
    class ImagesController < BaseController
      before_action :set_page
      before_action :set_post

      api :POST, '/pages/:page_id/posts/:post_id/images', "Upload an image to a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :file, File, required: true, desc: "Image file to upload"
      returns code: 201, desc: "Uploaded image URL"
      def create
        unless params[:file].present?
          render_error_message("File is required")
          return
        end

        attachment = @post.images.attach(params[:file]).last

        if attachment.persisted?
          render json: { url: url_for(attachment) }, status: :created
        else
          render_error_message("Failed to save image")
        end
      end

      api :DELETE, '/pages/:page_id/posts/:post_id/images/:id', "Delete an image from a post"
      param :page_id, :number, required: true, desc: "Page ID"
      param :post_id, :number, required: true, desc: "Post ID"
      param :id, :number, required: true, desc: "Image attachment ID"
      returns code: 204, desc: "Image deleted"
      def destroy
        attachment = @post.images.find(params[:id])
        attachment.purge
        head :no_content
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
