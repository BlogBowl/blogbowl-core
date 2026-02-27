module API
  module V1
    class ImagesController < BaseController
      api :POST, "/images/upload", "Upload an image and return its URL"
      param :file, File, required: true, desc: "Image file to upload"
      returns code: 201, desc: "Uploaded image URL"
      def upload
        unless params[:file].present?
          render_error_message("File is required")
          return
        end

        blob = ActiveStorage::Blob.create_and_upload!(
          io: params[:file].tempfile,
          filename: params[:file].original_filename,
          content_type: params[:file].content_type
        )

        render json: { url: url_for(blob) }, status: :created
      end
    end
  end
end
