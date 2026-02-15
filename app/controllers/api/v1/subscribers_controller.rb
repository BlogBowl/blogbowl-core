module API
  module V1
    class SubscribersController < BaseController
      before_action :set_newsletter

      def_param_group :subscriber_output do
        property :id, Integer, desc: "Subscriber ID"
        property :email, String, desc: "Subscriber email"
        property :verified, :boolean, desc: "Email verified"
        property :active, :boolean, desc: "Subscriber active"
        property :status, String, desc: "Subscriber status"
        property :newsletter_id, Integer, desc: "Newsletter ID"
        property :verified_at, String, desc: "Verification date"
        property :created_at, String, desc: "Creation date"
        property :updated_at, String, desc: "Updated date"
      end

      def_param_group :pagination do
        param :page, :number, desc: "Page number (default: 1)"
        param :size, :number, desc: "Items per page (default: 10, max: 100)"
      end

      api :GET, '/newsletters/:newsletter_id/subscribers', "List all subscribers for a newsletter"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :status, String, desc: "Filter by status"
      param :verified, :boolean, desc: "Filter by verification status"
      param_group :pagination
      returns code: 200, desc: "Paginated list of subscribers"
      def index
        subscribers = @newsletter.subscribers.order(created_at: :desc)
        subscribers = subscribers.where(status: params[:status]) if params[:status].present?
        subscribers = subscribers.where(verified: params[:verified]) if params[:verified].present?
        render_collection(subscribers) { |subscriber| subscriber_json(subscriber) }
      end

      api :POST, '/newsletters/:newsletter_id/subscribers', "Create a subscriber (upsert by email)"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :subscriber, Hash, desc: "Subscriber info", required: true do
        param :email, String, desc: "Subscriber email", required: true
        param :note, String, desc: "Optional note"
      end
      returns code: 200, desc: "Created or existing subscriber" do
        param_group :subscriber_output
      end
      def create
        # Upsert behavior: return existing subscriber if email exists
        existing = @newsletter.subscribers.find_by(email: subscriber_params[:email])
        if existing
          render_resource(existing) { |subscriber| subscriber_json(subscriber) }
          return
        end

        @subscriber = @newsletter.subscribers.new(subscriber_params)
        @subscriber.status = 'pending'
        @subscriber.ip_address = request.remote_ip

        if @subscriber.save
          render_resource(@subscriber, status: :created) { |subscriber| subscriber_json(subscriber) }
        else
          render_error(@subscriber.errors)
        end
      end

      api :DELETE, '/newsletters/:newsletter_id/subscribers/:id', "Remove a subscriber"
      param :newsletter_id, :number, required: true, desc: "Newsletter ID"
      param :id, :number, required: true, desc: "Subscriber ID"
      returns code: 204, desc: "Subscriber deleted"
      def destroy
        @subscriber = @newsletter.subscribers.find(params[:id])
        @subscriber.destroy
        head :no_content
      end

      private

      def set_newsletter
        @newsletter = @current_workspace.newsletters.find(params[:newsletter_id])
      end

      def subscriber_params
        params.require(:subscriber).permit(:email, :note)
      end

      def subscriber_json(subscriber)
        {
          id: subscriber.id,
          email: subscriber.email,
          verified: subscriber.verified,
          active: subscriber.active,
          status: subscriber.status,
          newsletter_id: subscriber.newsletter_id,
          verified_at: subscriber.verified_at,
          created_at: subscriber.created_at,
          updated_at: subscriber.updated_at
        }
      end
    end
  end
end
