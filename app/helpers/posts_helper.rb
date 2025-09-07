module PostsHelper
  def is_selected?(selected_value, item)
    if item.respond_to?(:slug)
      selected_value == item.slug
    else
      selected_value == item
    end
  end

  def sort_text(sort)
    {
      'newest' => 'Newest first',
      'oldest' => 'Oldest first',
      'title_asc' => 'Title A-Z',
      'title_desc' => 'Title Z-A'
    }[sort] || 'Newest first'
  end
end
