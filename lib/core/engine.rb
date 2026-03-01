module Core
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/app/abilities"
    config.autoload_paths << "#{root}/app/scrubbers"

    rake_tasks do
      load "tasks/openapi.rake"
    end

    # In standalone mode (CI), the engine IS the app, so Rails loads
    # config/routes.rb and db/migrate as the application paths. The engine
    # would then add them a second time, causing route name collisions and
    # DuplicateMigrationNameError. Clear the engine copies in that case.
    # Detect standalone mode by comparing engine root to Rails.root.
    initializer "core.deduplicate_paths", before: :add_routing_paths do
      if root.to_s == Rails.root.to_s
        paths["config/routes.rb"] = []
        paths["db/migrate"] = []
      end
    end
  end
end
