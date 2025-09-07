class PublicRouteConstraint
  def self.matches?(request)
    request.host != Rails.application.routes.default_url_options[:host]
  end
end
