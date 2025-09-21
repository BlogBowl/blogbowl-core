module Pages::ApplicationControllerConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_page
  end

  private
  def set_page
    @page = @workspace.pages.find_by(name_slug: params[:page_id])
    @page_settings = @page.settings
  end

end