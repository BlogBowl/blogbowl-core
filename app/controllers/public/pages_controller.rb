class Public::PagesController < Public::PageApplicationController
  def show
    @posts = @page.posts.published.limit(6)
    @latest_posts = @page.posts.published.limit(3)
    @categories = @page.categories

    posts_by_category = Post.find_by_sql([<<-SQL, @page.id, Post.statuses['published'], @page.id])
      SELECT p.*
      FROM categories c
      CROSS JOIN LATERAL (
        SELECT posts.*
        FROM posts
        WHERE posts.category_id = c.id
          AND posts.page_id = ?
          AND posts.status = ?
          AND posts.archived_at IS NULL
        ORDER BY posts.first_published_at DESC
        LIMIT 6
      ) p
      WHERE c.page_id = ?
    SQL

    posts_grouped = posts_by_category.group_by(&:category_id)

    @category_tree = @categories.map do |category|
      {
        category: category,
        posts: posts_grouped[category.id] || []
      }
    end.select { _1[:posts].any? }.sort_by { -(_1[:posts].size) }

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

  def show_view
    "public/#{@page_settings.template}/pages/index"
  end
end
