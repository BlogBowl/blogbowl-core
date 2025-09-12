# app/lib/feature_guard.rb
module FeatureGuard
  # Use a class instance variable to cache the status of each feature
  @features = {}

  # Method to register a feature and check if its keys are present
  def self.register(feature_name, required_keys:)
    # Check if all required keys are present and not blank
    is_enabled = required_keys.all?(&:present?)
    @features[feature_name.to_sym] = is_enabled
  end

  # The main method you'll use in your app
  def self.enabled?(feature_name)
    # Return false for any unregistered feature
    @features.fetch(feature_name.to_sym, false)
  end
end