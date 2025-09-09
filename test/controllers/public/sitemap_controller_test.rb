require_relative "../../test_helper"

class Public::SitemapControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = pages(:blog_with_domain_1)
    host! @page.domain
  end

  test "should get sitemap" do
    get public_sitemap_path(format: :xml)
    assert_response :success
    assert_equal "application/xml; charset=utf-8", @response.content_type
  end

  test "sitemap should use default domain" do
    get public_sitemap_path(format: :xml)
    assert_response :success
    assert @response.body.include?("http://#{@page.domain}")
  end

  test "sitemap should use base_domain when present" do
    @page.update(base_domain: "https://www.blogbowl.io")
    get public_sitemap_path(format: :xml)
    assert_response :success
    assert @response.body.include?("https://www.blogbowl.io")
    assert_not @response.body.include?(@page.domain)
  end

  test "sitemap should use subfolder when enabled" do
    @page.settings.update(subfolder_enabled: true)
    get public_sitemap_path(format: :xml)
    assert_response :success
    assert @response.body.include?("http://#{@page.domain}/#{@page.slug}")
  end

  test "sitemap should use base_domain and subfolder" do
    @page.update(base_domain: "https://www.blogbowl.io")
    @page.settings.update(subfolder_enabled: true)
    get public_sitemap_path(format: :xml)
    assert_response :success
    assert @response.body.include?("https://www.blogbowl.io/#{@page.slug}")
  end
end
