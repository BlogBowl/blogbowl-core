class Authentications::EventsController < ApplicationController
  def index
    @events = current_user.events.order(created_at: :desc)
  end
end
