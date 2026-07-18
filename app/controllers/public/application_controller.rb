class Public::ApplicationController < ActionController::Base
  skip_forgery_protection
  before_action :set_current_request_details
  before_action :set_page
  before_action :set_links
  layout :resolve_layout

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  protected

  def set_page
    @page = Page.find_by(domain: request.hostname)
    render_domain_not_found and return if @page.nil?

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

  # Absolute URL for a public path, mirroring PublicHelper#get_full_url.
  # Behind a reverse proxy the request host is the internal *.blogbowl.app
  # host, so redirects must be built from the configured base URL instead.
  # base_domain is accepted with or without a scheme.
  def public_url_for(path)
    full_path = "#{@path_prefix}#{path}"

    host = if @page_settings.subfolder_enabled && @page.base_domain.present?
      @page.base_domain
    else
      @page.domain
    end

    "https://#{host.strip.sub(%r{\Ahttps?://}i, '').chomp('/')}#{full_path}"
  end

  def render_not_found
    render "public/#{@page_settings.template}/404", status: :not_found
  end

  def render_domain_not_found
    render "public/404", status: :not_found, layout: false
  end

  def resolve_layout
    "public/#{@page_settings.template}"
  end
end
