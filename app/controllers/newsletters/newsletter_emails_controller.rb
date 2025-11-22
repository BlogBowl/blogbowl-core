class Newsletters::NewsletterEmailsController < Newsletters::ApplicationController
  include Pagy::Backend

  before_action :set_email, only: [:edit]

  layout :determine_layout

  def index
    newsletter_emails = @newsletter.newsletter_emails.order(created_at: :desc)
    # apply_filters
    @pagy, @emails = pagy(newsletter_emails, page: params[:page] || 1, limit: 10)
  end

  def new
    @email = @newsletter.newsletter_emails.build
  end

  def edit

  end

  def destroy

  end

  private

  def set_email
    @email = @newsletter.newsletter_emails.find_by(slug: params[:id])
    @subscribers_count = @newsletter.subscribers.active_and_verified.count
    @newsletter_settings_filled = @newsletter_settings.settings_filled
    render_not_found if @email.nil?
  end

  def determine_layout
    case action_name
    when 'new', 'edit'
      'editor'
    else
      'newsletter_dashboard' # Default layout for other actions
    end
  end

end
