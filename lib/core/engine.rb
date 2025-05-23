module Core
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{root}/app/abilities"
  end
end
