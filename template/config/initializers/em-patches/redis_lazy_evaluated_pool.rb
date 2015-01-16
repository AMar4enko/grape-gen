require 'redis-namespace'
require_relative 'redis'
require_relative 'lazy_evaluated_pool'

class RedisLazyEvaluatedPool < LazyEvaluatedPool
  CONFIG_DEFAULTS = {
      url: 'redis://localhost:6379/0',
      size: 10
  }
  private
  def self.connection
    Proc.new {
      config = RedisLazyEvaluatedPool::CONFIG_DEFAULTS.merge (@config|| {}).deep_symbolize_keys
      connection = EventMachine::Hiredis.connect(config[:url])
      connection = Redis::Namespace.new(config[:namespace], redis: connection) if config[:namespace]
      connection
    }
  end
end