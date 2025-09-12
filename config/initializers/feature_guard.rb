require 'feature_guard'

# --- Register your features here ---

# For Postmark (Email)
postmark_token = ENV.fetch('POSTMARK_ACCOUNT_TOKEN', nil) || Rails.application.credentials.dig(Rails.env.to_sym, :postmark, :account_token)
FeatureGuard.register(:postmark, required_keys: [postmark_token])