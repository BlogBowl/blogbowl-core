class API::Internal::Pages::PostRevisionsController < API::Internal::Pages::ApplicationController
  before_action :set_post

  def create
    authorize! :create, @post

    post_revision = @post.new_revision

    if post_revision.update(post_revision_params)
      render json: post_revision, status: :created
    else
      render json: post_revision.errors, status: :unprocessable_entity
    end
  end

  def update_last
    authorize! :edit, @post
    post_revision = @post.post_revisions.last
    render json: { error: 'Post does not have any revision' }, status: :conflict and return if post_revision.nil?

    if post_revision.update(post_revision_params)
      render json: post_revision.as_json.merge({ slug: @post.slug })
    else
      render json: post_revision.errors, status: :unprocessable_entity
    end
  end

  def show_last
    post_revision = @post.post_revisions.last
    render json: { error: 'Post revision not found' }, status: :not_found and return if post_revision.nil?
    render json: @post.post_revisions.last
  end

  def apply_last
    post_revision = @post.post_revisions.last
    render json: { error: 'Post does not have any revision' }, status: :conflict and return if post_revision.nil?

    post_revision.apply!
    render json: post_revision, status: :ok
  end

  def index
    render json: @post.post_revisions.order(updated_at: :desc).limit(20)
  end

  def share_last
    post_revision = @post.post_revisions.last

    if @post.authors.empty?
      render json: { error: "At least 1 author should be set" }, status: :unprocessable_entity
      return
    end

    if post_revision.share_id.nil?
      post_revision.share
    end

    render json: post_revision, status: :ok
  end

  private

  def current_ability
    @current_ability ||= PostAbility.new(current_user)
  end

  def set_post
    @post = @page.posts.find_by(id: params[:post_id] || params[:id])
    render json: { error: "Post not found" }, status: :not_found if @post.nil?
  end

  def post_revision_params
    params.permit(:title, :content_html, :seo_title, :seo_description, :og_title, :og_description, content_json: {})
  end
end
