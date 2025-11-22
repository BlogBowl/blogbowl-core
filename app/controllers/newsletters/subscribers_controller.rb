class Newsletters::SubscribersController < Newsletters::ApplicationController
  layout 'newsletter_dashboard'
  include Pagy::Backend

  def index
    @subscribers_count = @newsletter.subscribers.count
    # apply_filters
    @pagy, @subscribers = pagy(@newsletter.subscribers.order(created_at: :desc), page: params[:page] || 1, limit: 10)
  end


end
