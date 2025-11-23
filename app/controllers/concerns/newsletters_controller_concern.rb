module NewslettersControllerConcern
  extend ActiveSupport::Concern

  included do
    layout 'dashboard'
    before_action :ensure_postmark_is_configured, only: %i[create new]
  end

  def show
    redirect_to newsletters_newsletter_emails_url(@workspace.newsletters.find_by(name_slug: params[:id]))
  end

  def index
    @newsletters = @workspace.newsletters.order(created_at: :asc)
  end

  def new
    @newsletter = @workspace.newsletters.build
  end

  def create
    @newsletter = @workspace.newsletters.build(newsletter_param)

    if @newsletter.save
      flash[:notice] = 'New page was created successfully.'
      redirect_to newsletters_newsletter_emails_path(@newsletter)
    else
      flash.now[:alert] = @newsletter.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  rescue => e
    flash.now[:alert] = "There was an error creating new newsletter. Please, check logs."
    render :new, status: :unprocessable_entity
  end

  private

  def newsletter_param
    params.require(:newsletter).permit(:name)
  end

  def ensure_postmark_is_configured
    return if FeatureGuard.enabled?(:postmark)
    redirect_to newsletters_path, alert: "To use newsletter features add Postmark Account Token to ENV."
  end
end