module API::Internal::Newsletters::EmailsControllerConcern
  extend ActiveSupport::Concern

  included do
    skip_forgery_protection
    before_action :set_email, only: %i[show update create_image send_email unschedule_email send_test_email]
  end

  def create
    @email = @newsletter.newsletter_emails.build(email_params)

    if @email.save
      render json: @email.as_json, status: :created
    else
      render json: { errors: @email.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update

    if @email.sent?
      render json: { error: "Cannot update already sent email" }, status: :unprocessable_entity
      return
    end

    if @email.update(email_params)
      render json: @email, status: :ok
    else
      render json: { error: @email.errors.full_messages }, status: :unprocessable_entity
    end

  end

  def send_email
    if @newsletter.subscribers.active_and_verified.count == 0
      render json: { error: "No active and verified subscribers found" }, status: :unprocessable_entity
      return
    end
    if @email.sent?
      render json: { error: "Cannot send already sent email" }, status: :unprocessable_entity
      return
    end
    if @email.content_html.nil? or @email.content_json.nil?
      render json: { error: "Cannot send empty email" }, status: :unprocessable_entity
      return
    end
    if @email.author.nil?
      render json: { error: "Cannot send email without author" }, status: :unprocessable_entity
      return
    end
    if @email.subject.nil?
      render json: { error: "Cannot send email without subject" }, status: :unprocessable_entity
      return
    end
    unless @newsletter.settings.settings_filled
      render json: { error: "Before sending e-mail, please, fill newsletter settings!" }, status: :unprocessable_entity
      return
    end

    if params[:scheduled_at].present?
      scheduled_time = Time.parse(params[:scheduled_at]).utc
      @email.update(scheduled_at: params[:scheduled_at], status: :scheduled, postmark_tag: SecureRandom.uuid)
      job = SendNewsletterJob.set(wait_until: scheduled_time).perform_later(@email.id, @newsletter.id)
      @email.update(job_id: job.job_id)
    else
      @email.update(postmark_tag: SecureRandom.uuid)
      SendNewsletterJob.perform_now(@email.id, @newsletter.id)
      @email.reload
    end

    render json: @email.as_json, status: :ok
  end

  def unschedule_email
    unless @email.scheduled?
      render json: { error: "Email should be scheduled for unscheduling" }, status: :unprocessable_entity
      return
    end
    if @email.job_id.nil?
      render json: { error: "Email should have job id" }, status: :unprocessable_entity
      return
    end

    Sidekiq::ScheduledSet.new.find_job(@email.job_id)&.delete
    @email.update(job_id: nil, status: 'draft')

    render json: @email.as_json, status: :ok
  end

  def show
    render json: @email
  end

  def create_image
    attachment = @email.images.attach(params[:file]).last

    if attachment.persisted?
      render json: {
        url: url_for(attachment)
      }, status: :created
    else
      render json: { error: 'Failed to save image' }, status: :unprocessable_entity
    end
  end

  def send_test_email
    unless params[:emailAddress].present?
      render json: { error: 'emailAddress is required!' }, status: :unprocessable_entity
      return
    end

    if @email.content_html.nil?
      render json: { error: "Cannot send empty email" }, status: :unprocessable_entity
      return
    end
    if @email.author.nil?
      render json: { error: "Cannot send email without author" }, status: :unprocessable_entity
      return
    end
    if @email.subject.nil?
      render json: { error: "Cannot send email without subject" }, status: :unprocessable_entity
      return
    end

    NewsletterTestMailer.send_test_email(@email, @newsletter.settings, params[:emailAddress]).deliver_later
  end

  private

  def set_email
    @email = @newsletter.newsletter_emails.find_by(id: params[:id] || params[:email_id])
    render json: { error: "Email not found" }, status: :not_found if @email.nil?
  end


  def email_params
    params.permit(:subject, :preview, :content_html, :author_id, content_json: {})
  end

end