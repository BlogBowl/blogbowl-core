class Public::PostsController < Public::PageApplicationController
  before_action :set_post, only: [:show]

  def show
    if @post.nil?
      render_not_found
      return
    end
    @authors = @post.authors.where(post_authors: { role: 'author' })
    @reviewers = @post.authors.where(post_authors: { role: 'reviewer' })
    @main_author = @authors.first

    # Get contributing authors (excluding main author)
    @contributing_authors = @authors.where.not(id: @main_author.id) if @main_author.present?


    @category = @post.category
    render show_view
  end

  private

  def set_post
    @post = @page.posts.find_by(slug: params[:id], status: :published)
  end

  def show_view
    "public/#{@page_settings.template}/posts/show"
  end
end
