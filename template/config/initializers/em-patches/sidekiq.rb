require 'sidekiq'
require_relative 'redis'

module Sidekiq
  def self.redis=(hash)
    if hash.is_a?(LazyEvaluatedPool)
      @redis = hash
    else
      @_config_hash = hash
    end
  end
  class Client
    private
    def raw_push(payloads)
      @redis_pool.execute(false) do |conn|
        # No need to wait MULTI command to finish
        conn.async_command :multi
        # Atomic push commands is also async
        atomic_push(conn, payloads)
        # After pipeline is built, call synced EXEC command
        conn.exec
      end
      true
    end

    def atomic_push(conn, payloads)
      if payloads.first['at']
        conn.async_command(:zadd, 'schedule',payloads.map do |hash|
                                  at = hash.delete('at').to_s
                                  [at, Sidekiq.dump_json(hash)]
                                end)
      else
        q = payloads.first['queue']
        to_push = payloads.map { |entry| Sidekiq.dump_json(entry) }
        conn.async_command(:sadd, 'queues', q)
        conn.async_command(:lpush,"queue:#{q}", to_push)
      end
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = RedisLazyEvaluatedPool.pool_with_config(ApplicationSettings.sidekiq.redis)
end

SIDEKIQ_ON_EM = true