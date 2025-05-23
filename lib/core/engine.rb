module Core
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/app/abilities"
    config.autoload_paths << "#{root}/app/scrubbers"
  end
end
