module Core
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/app/abilities"
    config.autoload_paths << "#{root}/app/scrubbers"

    # Clear the engine's routes path so it doesn't draw config/routes.rb
    # a second time. Routes are already drawn by Rails.application.routes.draw
    # in config/routes.rb. Without this, standalone mode (CI) loads routes
    # twice, causing "Invalid route name, already in use" errors.
    paths["config/routes.rb"] = []
  end
end
