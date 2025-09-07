class API::Internal::Pages::PostsController < API::Internal::Pages::ApplicationController
  before_action :set_post, only: %i[show publish update]

  def create
    @post = @page.posts.build(post_params)
    authorize! :create, @post

    if @post.save
      render json: @post, status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize! :edit, @post

    params = post_params
    unless params[:author_ids].nil?
      @post.post_authors = @post.post_authors.reject { _1.role == 'author' }
      @post.post_authors << params[:author_ids].map { PostAuthor.build(post: @post, author_id: _1, role: 'author') }
      params.delete(:author_ids)
    end
    unless params[:reviewer_ids].nil?
      @post.post_authors = @post.post_authors.reject { _1.role == 'reviewer' }
      @post.post_authors << params[:reviewer_ids].map { PostAuthor.build(post: @post, author_id: _1, role: 'reviewer') }
      params.delete(:reviewer_ids)
    end

    if @post.update(params)
      render json: @post, status: :ok
    else
      render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def publish
    authorize! :edit, @post

    if @post.authors.empty?
      render json: { error: "At least 1 author should be set" }, status: :unprocessable_entity
      return
    end

    @post.publish!
    render json: @post
  end

  def show
    render json: @post
  end

  private

  def current_ability
    @current_ability ||= PostAbility.new(current_user)
  end

  def set_post
    @post = @page.posts.find_by(id: params[:post_id] || params[:id])
    render json: { error: "Post not found" }, status: :not_found if @post.nil?
  end

  def post_params
    params.permit(:title, :content_html, :category_id, :seo_title, :seo_description, :cover_image, :sharing_image, :description, :og_title, :og_description, content_json: {}, reviewer_ids: [], author_ids: [])
  end
end
