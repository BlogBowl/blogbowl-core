class Pages::PostsController < Pages::ApplicationController
  include Pagy::Backend

  before_action :set_post, only: [:edit, :destroy, :publish]

  layout "editor", :only => [:new, :edit]

  def index
    @posts = @page.posts
    apply_filters
    @pagy, @posts = pagy(@posts, page: params[:page] || 1, limit: 10)
  end

  def new
    @post = @page.posts.build
    authorize! :create, @post
  end

  def edit
    @revision = @post.post_revisions.last
  end

  def destroy
    authorize! :destroy, @post

    if @post.update(archived_at: Time.current)
      flash[:notice] = 'Post was successfully archived.'
      redirect_to pages_posts_path
    else
      flash[:alert] = @post.errors.full_messages.to_sentence
      redirect_to pages_posts_path
    end
  end

  def publish
    authorize! :edit, @post

    @post.publish!
    flash[:notice] = 'Post was successfully published.'
    redirect_to pages_posts_path
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.to_sentence
    redirect_to pages_posts_path
  end

  def draft
    @post = @page.posts.unscoped.find_by(slug: params[:id])
    render_not_found and return if @post.nil?
    authorize! :edit, @post

    if @post.update(status: 'draft', archived_at: nil)
      flash[:notice] = 'Post was successfully drafted.'
      redirect_to pages_posts_path
    else
      flash[:alert] = @post.errors.full_messages.to_sentence
      redirect_to pages_posts_path
    end
  end

  private

  def apply_filters
    # Apply status filter
    if params[:status].present?
      @selected_status = params[:status]
      case params[:status]
      when 'published'
        @posts = @posts.where(status: :published)
      when 'draft'
        @posts = @posts.where(status: :draft)
      when 'archived'
        @posts = @page.posts.unscoped.where.not(archived_at: nil)
      end
    end

    # Apply author filter
    if params[:author_slug].present?
      @selected_author = @page.authors.find_by(slug: params[:author_slug])
      @posts = @posts.joins(:authors)
                     .where(authors: { slug: params[:author_slug] })
                     .distinct
    end

    # Apply category filter
    if params[:category_slug].present?
      @selected_category = @page.categories.find_by(slug: params[:category_slug])
      @posts = @posts.joins(:category)
                     .where(category: { slug: params[:category_slug] })
                     .distinct
    end

    # Apply sorting
    if params[:sort].present?
      @selected_sort = params[:sort]
      case params[:sort]
      when 'oldest'
        @posts = @posts.order(created_at: :asc)
      when 'title_asc'
        @posts = @posts.order(title: :asc)
      when 'title_desc'
        @posts = @posts.order(title: :desc)
      else
        @posts = @posts.order(created_at: :desc)
      end
    end

  end

  def current_ability
    @current_ability ||= PostAbility.new(current_user)
  end

  def set_post
    @post = @page.posts.find_by(slug: params[:id])
    render_not_found if @post.nil?
  end

  def post_params
    params.require(:post).permit(:title, :content_html, :content_json)
  end
end
