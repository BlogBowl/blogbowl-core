class Public::ApplicationController < ActionController::Base
  before_action :set_page
  before_action :set_links
  layout :resolve_layout

  protected

  def set_page
    @page = Page.find_by(domain: request.hostname)
    render_domain_not_found if @page.nil?

    @workspace = @page.workspace
    @workspace_settings = @workspace.settings

    set_page_setting
  end

  def set_links
    return unless @page

    @navbar_links = @page.links.header.order(:order)
    @footer_links = @page.links.footer.where(link_type: "link").order(:order)
    @social_media_links = @page.links.where(link_type: "social_media").order(:order)
  end

  def set_page_setting
    @page_settings = @page.settings
    @path_prefix = "/#{@page.slug}" if @page_settings.subfolder_enabled
  end

  def render_not_found
    render "public/#{@page_settings.template}/404", status: :not_found
  end

  def render_domain_not_found
    @page_settings = PageSetting.new(template: "blog_1")
    render "public/#{@page_settings.template}/404", status: :not_found
  end

  def resolve_layout
    "public/#{@page_settings.template}"
  end

end
