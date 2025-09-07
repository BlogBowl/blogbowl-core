class API::Internal::Pages::ApplicationController < API::Internal::ApplicationController
  before_action :set_page

  private

  def set_page
    @page = @workspace.pages.find(params[:page_id])
  end
end