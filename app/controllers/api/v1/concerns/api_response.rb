module API::V1::APIResponse
  extend ActiveSupport::Concern

  include Pagy::Backend

  DEFAULT_LIMIT = 10
  MAX_LIMIT = 100

  # Render a single resource (unwrapped)
  def render_resource(resource, status: :ok, &block)
    render json: block_given? ? block.call(resource) : resource, status: status
  end

  # Render a collection with pagination envelope using Pagy
  def render_collection(scope, &block)
    limit = pagination_limit
    pagy, records = pagy(scope, limit: limit, page: params[:page])

    result = block_given? ? records.map { |item| block.call(item) } : records

    render json: {
      page: pagy.page,
      size: pagy.limit,
      total: pagy.count,
      result: result
    }
  end

  # Render validation errors in consistent format
  def render_error(errors, status: :unprocessable_entity)
    normalized = normalize_errors(errors)
    render json: { errors: normalized }, status: status
  end

  # Render a simple error message
  def render_error_message(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end

  private

  def pagination_limit
    limit = (params[:size] || DEFAULT_LIMIT).to_i
    [[limit, 1].max, MAX_LIMIT].min
  end

  def normalize_errors(errors)
    case errors
    when ActiveModel::Errors
      errors.map do |error|
        { field: error.attribute.to_s, message: error.message }
      end
    when Hash
      errors.map { |field, messages| { field: field.to_s, message: Array(messages).first } }
    when Array
      errors.map { |msg| { field: 'base', message: msg } }
    else
      [{ field: 'base', message: errors.to_s }]
    end
  end
end
