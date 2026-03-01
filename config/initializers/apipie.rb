Apipie.configure do |config|
  config.app_name                = "BlogBowl API"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apidoc"
  config.app_info                = "REST API for managing blog pages, posts, authors, newsletters, and subscribers."
  config.api_controllers_matcher = [Core::Engine.root.join("app/controllers/api/v1/**/*.rb").to_s]
  config.validate                = false
  config.generator.swagger.content_type_input = :json
end
