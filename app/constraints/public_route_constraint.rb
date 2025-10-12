class PublicRouteConstraint
  def self.matches?(request)
    Rails.logger.warn "Request host: #{request.host} | Rails default host: #{Rails.application.routes.default_url_options[:host]}"
    request.host != Rails.application.routes.default_url_options[:host]
  end
end
