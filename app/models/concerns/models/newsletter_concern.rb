module Models::NewsletterConcern
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
    belongs_to :workspace

    has_many :newsletter_emails
    has_many :subscribers, dependent: :destroy
    has_many :page_settings
    has_one :settings, dependent: :destroy, class_name: 'NewsletterSetting'

    validates :name_slug, presence: true
    validates :name, presence: true, uniqueness: { scope: :workspace_id }

    before_validation :generate_uuid, on: :create
    before_validation :generate_slug, if: :name_changed?

    after_create do
      unless Rails.env.test?
        create_postmark_server(workspace.uuid)
      end
      create_settings
    end
  end

  def to_param
    name_slug
  end

  private

  def create_postmark_server(name)
    account_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :account_token))
    client = Postmark::AccountApiClient.new(account_token)

    result = client.create_server(name: name, color: Rails.env.development? ? 'blue' : 'red', track_opens: true, track_links: "HtmlAndText", delivery_type: Rails.env.development? ? "Sandbox" : 'Live')

    server_client = Postmark::ApiClient.new(result[:api_tokens].first)
    x_api_key = ENV.fetch('POSTMARK_X_API_KEY', Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :x_api_key))
    webhook = server_client.create_webhook(
      "Url": api_public_postmark_event_url,
      "MessageStream": "broadcast",
      "HttpHeaders": [
        {
          "Name": "X-Api-Key",
          "Value": x_api_key
        }
      ],
      "Triggers": {
        "Open": {
          "Enabled": true,
          "PostFirstOpenOnly": true
        },
        "Click": {
          "Enabled": true
        },
        "Delivery": {
          "Enabled": true
        },
        "Bounce": {
          "Enabled": true,
          "IncludeContent": false
        },
        "SpamComplaint": {
          "Enabled": true,
          "IncludeContent": false
        },
        "SubscriptionChange": {
          "Enabled": true
        }
      })

    update(
      postmark_server_id: result[:id],
      postmark_server_token: result[:api_tokens].first
    )

  rescue => e
    Rails.logger.error "Failed to create postmark server: #{e.message}"
    AppLogger.notify_exception(e, extra_context: { newsletter_id: id, name: name })

    raise e
  end

  def generate_slug
    new_slug = name.parameterize

    return if Newsletter.exists?(name_slug: new_slug, workspace_id: workspace_id)

    self.name_slug = new_slug
  end

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end