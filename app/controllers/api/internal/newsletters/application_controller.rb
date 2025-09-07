class API::Internal::Newsletters::ApplicationController < API::Internal::ApplicationController
  before_action :set_newsletter

  private

  def set_newsletter
    @newsletter = @workspace.newsletters.find(params[:newsletter_id])
  end
end