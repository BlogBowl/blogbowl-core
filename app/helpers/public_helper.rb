require "nokogiri"

module PublicHelper
  include Pagy::Frontend

  def pagy_url_for(pagy, page, absolute: false)
    params = request.query_parameters.merge(pagy.vars[:page_param] => page, only_path: !absolute)
    url_for(params)
  end

  def format_date(date)
    date.strftime("%B %d, %Y")
  end

  def format_datetime(date)
    date.strftime("%Y-%m-%d")
  end

  def author_name(author)
    if author.first_name.present? and author.last_name.present?
      "#{author.first_name} #{author.last_name}"
    elsif author.first_name.present?
      author.first_name
    elsif author.last_name.present?
      author.last_name
    else
      author.email
    end
  end

  def generate_toc(html_content, options = {})
    doc = Nokogiri::HTML.fragment(html_content)
    headings = doc.css("h2, h3")

    return "" if headings.empty?

    default_options = {
      container_class: "flex flex-col gap-y-1",
      item_class: "rounded-xs text-slate-500 hover:text-slate-700 active:opacity-text-slate-600",
      link_class: "block py-1 px-2",
      active_item_class: "",
      active_link_class: "text-slate-700 font-bold",
      inactive_link_class: "text-slate-500",
      indent_class: "pl-4"
    }

    options = default_options.merge(options)

    toc = "<ul id='table-of-contents' class='#{options[:container_class]}'>"
    headings.each do |heading|
      level = heading.name[1].to_i
      id = heading["id"]
      text = heading.text.strip

      item_class = level == 3 ? "#{options[:item_class]} #{options[:indent_class]}" : options[:item_class]

      toc += "<li class='#{item_class}' data-active-class='#{options[:active_item_class]}'>"
      toc += "<a href='##{id}' class='#{options[:link_class]} text-sm' "
      toc += "data-active-class='#{options[:active_link_class]}' "
      toc += "data-inactive-class='#{options[:inactive_link_class]}'>"
      toc += "#{text}</a></li>"
    end
    toc += "</ul>"

    toc.html_safe
  end

  def dynamic_prefix(path)
    @path_prefix.present? ? "#{@path_prefix}#{path}" : path
  end

  def get_full_url(path)
    unless @page_settings.subfolder_enabled
      # TODO: should we add www to it??
      return "https://#{@page.domain}#{path}"
    end
    path
  end

  def get_category_url(category)
    get_full_url(dynamic_prefix("/category/#{category.slug}"))
  end

  def get_post_og_image_url(post)
    if post.sharing_image.present?
      Rails.application.routes.url_helpers.url_for(post.sharing_image)
    elsif post.cover_image.present?
      Rails.application.routes.url_helpers.url_for(post.cover_image)
    else
      ""
    end
  end

  def get_amount_of_words(article)
    article.content_html.present? ? Nokogiri::HTML.fragment(article.content_html).children.map(&:text).join(" ").split.size : 0
  end

  def get_read_time(article)
    amount_of_words = get_amount_of_words(article)
    amount_of_minutes = (amount_of_words / 225).round(1)
    if amount_of_minutes > 1
      "#{amount_of_minutes} minutes"
    else
      "#{[amount_of_minutes, 1].max} minute"
    end
  end

  def show_progress_bar?
    # Customize this condition based on your needs
    controller_name == "posts" && action_name == "show"
  end

  def pagy_navigation
    if @pagy.pages > 1
      content_tag(:div, class: "flex items-center justify-center mt-10") do
        pagy_nav(@pagy).html_safe
      end
    end
  end
end
