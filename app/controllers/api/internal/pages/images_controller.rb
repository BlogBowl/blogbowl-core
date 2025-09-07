class API::Internal::Pages::ImagesController < API::Internal::Pages::ApplicationController
  before_action :set_post

  def create
    attachment = @post.images.attach(params[:file]).last

    if attachment.persisted?
      render json: {
        url: url_for(attachment)
      }, status: :created
    else
      render json: { error: 'Failed to save image' }, status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
