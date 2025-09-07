class Public::PageApplicationController < Public::ApplicationController
  def render_not_found
    render "public/#{@page_settings.template}/404", status: :not_found
  end

end