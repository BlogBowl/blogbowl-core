class API::Internal::AuthorsController < API::Internal::ApplicationController
  def index
    render json: @workspace.authors.where(active: true)
  end

end
