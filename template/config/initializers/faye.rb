require_relative '../../lib/faye_publisher'

FayePublisher.redis = ApplicationSettings.faye.redis unless FayePublisher.configured?