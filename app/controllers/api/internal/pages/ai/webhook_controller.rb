class API::Internal::Pages::AI::WebhookController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :verify_api_key

  def create_post
    @page = Page.find(params["page_id"])
    @topic = @page.page_topics.find(params["topic_id"])

    if @topic.status == 'generated'
      render json: { error: "Topic was already generated!" }
      return
    end

    category_id = @topic.category_id || @page.categories.first&.id
    author_id = @page.authors.first&.id
    if category_id.nil? || author_id.nil?
      render json: { error: "Category ID or author ID is undefined" }
      return
    end

    post = @page.create_post_with_revision(
      @topic.title,
      params["content_html"],
      params["content_json"],
      params["description"],
      category_id,
      author_id,
      params["cover_image"],
      true
    )

    if post.nil?
      render json: { error: "There was an creating post" }
      return
    end

    @topic.mark_as_generated(post.id, params["cost"] || 0)

    GeneratedPostMailer.post_generated(post.id).deliver_later

    # Upsert forum opportunities
    if params["forums"].present?
      params["forums"].each do |forum|
        @page.forum_opportunities.find_or_create_by(url: forum["url"]) do |opportunity|
          opportunity.title = forum["title"]
        end
      end
    end

    # Upsert people questions
    if params["questions"].present?
      params["questions"].each do |question_text|
        @page.people_questions.find_or_create_by(question: question_text)
      end
    end

    render json: { post_id: post.id }
  rescue => e
    Rails.logger.error "Failed to create post: #{e.message}"
    # TODO: PRO
    # Sentry.capture_exception(e, extra: { workspace_id: @page.workspace_id, page_id: @page.id })
    render json: { error: "There was an creating post" }
  end

  private

  def verify_api_key
    expected_api_key = ENV.fetch('AI_X_API_KEY', Rails.application.credentials[Rails.env.to_sym][:ai][:x_api_key])
    provided_api_key = request.headers['X-Api-Key']

    # Check if the API key matches
    unless provided_api_key && provided_api_key == expected_api_key
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end
end