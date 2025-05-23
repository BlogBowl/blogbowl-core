class Public::PagesController < Public::PageApplicationController
  def show
    @posts = @page.posts.published.order(created_at: :desc).limit(6)
    @latest_posts = @page.posts.published.order(created_at: :desc).limit(3)
    @categories = @page.categories
    @category_tree = @categories.map { |category| build_category_tree(category) }.select { _1[:posts].any? }.sort_by { -(_1[:posts].count) }

    render show_view
  end

  def robots
    robots_content = render_to_string(
      file: Rails.root.join('app', 'views', 'public', 'shared', '_robots.txt.erb'),
      formats: [:html],
      layout: nil
    )

    render plain: robots_content, content_type: 'text/plain'
  end

  private

  def build_category_tree(category)
    {
      category: category,
      posts: @posts.where(category_id: category.id)
    }
  end

  def show_view
    "public/#{@page_settings.template}/pages/index"
  end
end
