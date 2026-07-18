class Public::PostsController < Public::PageApplicationController
  before_action :set_post, only: [ :show ]

  def show
    if @post.nil?
      render_not_found
      return
    end

    # A redirect whose target has gone away resolves to nil; fall through and
    # render the post rather than sending the visitor nowhere.
    destination = @post.redirect_destination(path_prefix: @path_prefix.to_s)
    if destination.present?
      redirect_to destination, status: :moved_permanently, allow_other_host: true
      return
    end

    @authors = @post.authors.where(post_authors: { role: "author" })
    @reviewers = @post.authors.where(post_authors: { role: "reviewer" })
    @main_author = @authors.first

    # Get contributing authors (excluding main author)
    @contributing_authors = @authors.where.not(id: @main_author.id) if @main_author.present?


    @category = @post.category
    render show_view
  end

  # Permanent redirect from the legacy /posts/:id URLs to /:id.
  # @path_prefix keeps the page slug when the page is served from a subfolder.
  def legacy_show_redirect
    redirect_to "#{@path_prefix}/#{params[:id]}", status: :moved_permanently, allow_other_host: false
  end

  private

  def set_post
    @post = @page.posts.find_by(slug: params[:id], status: :published)
  end

  def show_view
    "public/#{@page_settings.template}/posts/show"
  end
end
