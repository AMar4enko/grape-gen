require 'connection_pool'
require 'em-synchrony/connection_pool'

module Faye
  module Publisher
    class << self
      def instance
        @default_instance ||= RedisPublisher.new(configuration.redis)
      end

      def configure
        yield(configuration)
      end

      def configured?
        !@config.nil?
      end

      private
      def configuration
        @config ||= OpenStruct.new(redis: {url: 'redis://localhost:6379', size: 10, namespace: 'faye'})
      end
    end

    class RedisPublisher
      def initialize(config)
        case config
          when
          ::ConnectionPool,
              EventMachine::Synchrony::ConnectionPool
            @redis = config
          else
            @config = config
        end
      end

      def publish(channel, payload)
        redis.rpush(
            'faye.messages',
            MultiJson.dump(
                channel: channel,
                payload: payload
            )
        )
      end

      private
      def redis
        @redis ||= ConnectionPool::Wrapper.new(size: @config[:size] || 10) do
          connection = Redis.new(url: @config[:url])
          connection = Redis::Namespace.new(@config[:namespace], redis: connection) if @config[:namespace]
          connection
        end
      end
    end
  end
end