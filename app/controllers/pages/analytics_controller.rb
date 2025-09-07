class Pages::AnalyticsController < Pages::ApplicationController
  def index
    @iframe_url = "#{UmamiService::BASE_URL}/teams/#{@workspace.umami_team_id}/websites/#{@page.umami_website_id}"
  end
end
