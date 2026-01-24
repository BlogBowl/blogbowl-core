xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc public_root_url(host: @host, protocol: @protocol, script_name: @path_prefix)
    if @last_post_updated_at.present?
      xml.lastmod @last_post_updated_at.strftime("%Y-%m-%d")
    end
    xml.changefreq "weekly"
    xml.priority "1.0"
  end

  @posts.each do |post|
    xml.url do
      xml.loc public_post_url(post, host: @host, protocol: @protocol, script_name: @path_prefix)
      xml.lastmod post.updated_at.strftime("%Y-%m-%d")
      xml.changefreq "monthly"
      xml.priority "0.8"
    end
  end

  @categories.each do |category|
    xml.url do
      xml.loc public_category_url(category, host: @host, protocol: @protocol, script_name: @path_prefix)
      xml.changefreq "weekly"
      xml.priority "0.5"
    end
  end

  @authors.each do |author|
    xml.url do
      xml.loc public_author_url(author, host: @host, protocol: @protocol, script_name: @path_prefix)
      xml.changefreq "weekly"
      xml.priority "0.5"
    end
  end
end
