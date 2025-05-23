module BreadcrumbHelper
  def category_breadcrumbs
    breadcrumbs = [
      {
        title: "Home",
        url: get_full_url(dynamic_prefix(''))
      },
      {
        title: "Categories",
        url: get_full_url(dynamic_prefix(public_categories_path))
      },
    ]

    # Add the parent category breadcrumb if it exists
    if @category.parent.present?
      breadcrumbs << { title: @category.parent.name, url: get_full_url(dynamic_prefix(public_category_path(@category.parent))) }
    end

    # Add the current category breadcrumb
    breadcrumbs << { title: @category.name }
    breadcrumbs
  end

  def author_breadcrumbs
    [
      {
        title: "Home",
        url: get_full_url(dynamic_prefix(''))
      },
      {
        title: "Authors",
        url: get_full_url(dynamic_prefix(public_authors_path))
      },
      {
        title: @author.formatted_name
      }
    ]
  end

  def default_breadcrumbs(title)
    [
      {
        title: "Home",
        url: get_full_url(dynamic_prefix(''))
      },
      {
        title: title,
      }
    ]
  end
  def render_breadcrumbs(breadcrumbs)
    content_tag :nav, class: "flex items-center" do
      breadcrumbs.map.with_index do |breadcrumb, index|
        if breadcrumb[:url].present?
          if breadcrumb[:title] == "Blog"
            link_to(content_tag(:i, nil, class: "iconoir-home-simple-door"), breadcrumb[:url])
          else
            link_to(breadcrumb[:title], breadcrumb[:url])
          end
        else
          content_tag(:span, breadcrumb[:title], class: "font-bold")
        end
      end.join(' <i class="iconoir-nav-arrow-right text-xl"></i> ').html_safe
    end
  end


end
