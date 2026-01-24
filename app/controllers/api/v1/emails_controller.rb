module API
  module V1
    class EmailsController < BaseController
      before_action :set_newsletter
      before_action :set_email, only: [:show, :update, :destroy, :send_email]

      def_param_group :email_output do
        property :id, Integer, desc: "Email ID"
        property :subject, String, desc: "Email subject"
        property :preview, String, desc: "Email preview text"
        property :slug, String, desc: "Email slug"
        property :status, String, desc: "Email status (draft, scheduled, sent, failed)"
        property :content_html, String, desc: "Email HTML content"
        property :content_json, Hash, desc: "Email JSON content"
        property :author_id, Integer, desc: "Author ID"
        property :newsletter_id, Integer, desc: "Newsletter ID"
        property :scheduled_at, String, desc: "Scheduled send date"
        property :sent_at, String, desc: "Actual send date"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/newsletters/:newsletter_id/emails', "List all emails for a newsletter"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :status, String, desc: "Filter by status (draft, scheduled, sent, failed)"
      param_group :pagination
      returns code: 200, desc: "Paginated list of emails"
      def index
        emails = @newsletter.newsletter_emails.order(created_at: :desc)
        emails = emails.where(status: params[:status]) if params[:status].present?
        render_collection(emails) { |email| email_json(email) }
      end

      api :GET, '/newsletters/:newsletter_id/emails/:id', "Get a specific email"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :id, :number, required: true, desc: "Email ID"
      returns code: 200, desc: "Email details" do
        param_group :email_output
      end
      def show
        render_resource(@email) { |email| email_json(email) }
      end

      api :POST, '/newsletters/:newsletter_id/emails', "Create a new email"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :email, Hash, desc: "Email info", required: true do
        param :subject, String, desc: "Email subject", required: true
        param :preview, String, desc: "Email preview text"
        param :content_html, String, desc: "Email HTML content"
        param :content_json, Hash, desc: "Email JSON content"
        param :author_id, Integer, desc: "Author ID"
      end
      returns code: 201, desc: "Created email" do
        param_group :email_output
      end
      def create
        @email = @newsletter.newsletter_emails.new(email_params)
        @email.status = 'draft'

        if @email.save
          render_resource(@email, status: :created) { |email| email_json(email) }
        else
          render_error(@email.errors)
        end
      end

      api :PATCH, '/newsletters/:newsletter_id/emails/:id', "Update an email (draft only)"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :id, :number, required: true, desc: "Email ID"
      param :email, Hash, desc: "Email info", required: true do
        param :subject, String, desc: "Email subject"
        param :preview, String, desc: "Email preview text"
        param :content_html, String, desc: "Email HTML content"
        param :content_json, Hash, desc: "Email JSON content"
        param :author_id, Integer, desc: "Author ID"
      end
      returns code: 200, desc: "Updated email" do
        param_group :email_output
      end
      def update
        if @email.status != 'draft'
          render_error_message("Cannot update email with status '#{@email.status}'", status: :unprocessable_entity)
          return
        end

        if @email.update(email_params)
          render_resource(@email) { |email| email_json(email) }
        else
          render_error(@email.errors)
        end
      end

      api :DELETE, '/newsletters/:newsletter_id/emails/:id', "Delete an email (draft only)"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :id, :number, required: true, desc: "Email ID"
      returns code: 204, desc: "Email deleted"
      def destroy
        if @email.status != 'draft'
          render_error_message("Cannot delete email with status '#{@email.status}'", status: :unprocessable_entity)
          return
        end

        @email.destroy
        head :no_content
      end

      api :POST, '/newsletters/:newsletter_id/emails/:id/send', "Send or schedule an email"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :id, :number, required: true, desc: "Email ID"
      param :scheduled_at, String, desc: "Schedule for future (ISO 8601 format). Omit to send immediately."
      returns code: 200, desc: "Email queued for sending" do
        param_group :email_output
      end
      def send_email
        # Validate email has required content
        if @email.content_html.blank?
          render_error_message("Cannot send email without content", status: :unprocessable_entity)
          return
        end

        if @email.subject.blank?
          render_error_message("Cannot send email without subject", status: :unprocessable_entity)
          return
        end

        # Check for active verified subscribers
        active_subscribers = @newsletter.subscribers.where(active: true, verified: true)
        if active_subscribers.empty?
          render_error_message("Cannot send email without active and verified subscribers", status: :unprocessable_entity)
          return
        end

        # Handle scheduling
        if params[:scheduled_at].present?
          scheduled_time = Time.parse(params[:scheduled_at])

          if scheduled_time <= Time.current
            render_error_message("scheduled_at must be in the future", status: :unprocessable_entity)
            return
          end

          @email.update(status: 'scheduled', scheduled_at: scheduled_time)
          SendNewsletterJob.set(wait_until: scheduled_time).perform_later(@email.id)
        else
          # Send immediately
          @email.update(status: 'scheduled')
          SendNewsletterJob.perform_later(@email.id)
        end

        render_resource(@email) { |email| email_json(email) }
      end

      private

      def set_newsletter
        @newsletter = @current_workspace.newsletters.find(params[:newsletter_id])
      end

      def set_email
        @email = @newsletter.newsletter_emails.find(params[:id])
      end

      def email_params
        params.require(:email).permit(:subject, :preview, :content_html, :content_json, :author_id)
      end

      def email_json(email)
        {
          id: email.id,
          subject: email.subject,
          preview: email.preview,
          slug: email.slug,
          status: email.status,
          content_html: email.content_html,
          content_json: email.content_json,
          author_id: email.author_id,
          newsletter_id: email.newsletter_id,
          scheduled_at: email.scheduled_at,
          sent_at: email.sent_at,
          created_at: email.created_at,
          updated_at: email.updated_at
        }
      end
    end
  end
end
