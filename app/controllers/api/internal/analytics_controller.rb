class API::Internal::AnalyticsController < API::Internal::ApplicationController


  def show_user
    render json: { id: @workspace.umami_user_id }
  end
end
