require_relative 'redis_lazy_evaluated_pool'
require_relative '../../../lib/faye_publisher'

FayePublisher.redis = RedisLazyEvaluatedPool.pool_with_config(ApplicationSettings.faye.redis.to_hash.deep_symbolize_keys)