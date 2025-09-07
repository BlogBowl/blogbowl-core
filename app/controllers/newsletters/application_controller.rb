class Newsletters::ApplicationController < ApplicationController
  before_action :set_newsletter

  def set_newsletter
    @newsletter = @workspace.newsletters.find_by(name_slug: params[:newsletter_id])
    @newsletter_settings = @newsletter.settings
  end


end