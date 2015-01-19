require_relative '../../lib/faye/publisher'

Faye::Publisher.configure do |config|
  config.redis = ApplicationSettings.faye.redis unless Faye::Publisher.configured?
end