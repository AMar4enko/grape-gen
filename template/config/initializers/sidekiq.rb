require 'redis-namespace'

if RACK_ENV == 'test'
  require 'sidekiq/testing'
  Sidekiq::Testing.fake!
else
  Sidekiq.configure_server do |config|
    config.redis = ApplicationSettings.sidekiq.redis
  end

  Sidekiq.configure_client do |config|
    config.redis = ApplicationSettings.sidekiq.redis unless defined?(SIDEKIQ_ON_EM)
  end
end
Sidekiq::Logging.logger = Logging.logger[:sidekiq]