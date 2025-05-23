require_relative "lib/core/version"

Gem::Specification.new do |spec|
  spec.name = "core"
  spec.version = Core::VERSION
  spec.authors = ["SOMF"]
  spec.email = ["general@blogbowl.io"]
  spec.homepage = "https://blogbowl.io"
  spec.summary = "Summary of Core."
  spec.description = "Description of Core."

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"

  spec.add_dependency "cancancan", "~> 3.6"

  spec.add_dependency "nokogiri", "~> 1.18"

  spec.add_dependency "bcrypt", "~> 3.1"

  spec.add_dependency "pagy", "~> 9.3"

  spec.add_dependency "active_storage_validations", "~> 2.0"

  spec.add_dependency "rack-mini-profiler", "~> 3.3"
  spec.add_dependency "memory_profiler", "~> 1.1"
  spec.add_dependency "stackprof", "~> 0.2.27"
end


