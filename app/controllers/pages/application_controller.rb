class Pages::ApplicationController < ApplicationController
  before_action :set_page

  def set_page
    @page = @workspace.pages.find_by(name_slug: params[:page_id])
    @page_settings = @page.settings
  end


end