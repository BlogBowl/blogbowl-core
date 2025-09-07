class API::Internal::DomainsController < ActionController::Base
  def verify
    domain = params[:domain]
    render json: nil, status: :not_found and return if domain.blank?

    if Page.exists?(domain:)
      render json: nil, status: :ok
    else
      render json: nil, status: :not_found
    end
  end
end
