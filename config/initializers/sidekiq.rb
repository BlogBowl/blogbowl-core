Sidekiq.configure_server do |config|
  config.redis = Rails.application.config_for('redis/shared')
  config.queues = %w[default newsletter postmark_webhooks]
end

Sidekiq.configure_client do |config|
  config.redis = Rails.application.config_for('redis/shared')
end