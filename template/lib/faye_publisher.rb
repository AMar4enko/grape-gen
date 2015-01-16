require 'connection_pool'
require 'em-synchrony/connection_pool'

module FayePublisher
  FakePublishing = Struct.new(:channel, :payload)
  class << self
    def fake!
      @fake = true
    end

    def redis=(arg)
      case arg
        when
        ::ConnectionPool,
            EventMachine::Synchrony::ConnectionPool # Or its descendants
          @redis = arg
        else
          @_config = arg
      end
    end

    def redis
      @redis ||= begin
        config = ApplicationSettings.faye.redis
        ConnectionPool::Wrapper.new(size: config[:size] || 10) do
          connection = Redis.new(url: config[:url])
          connection = Redis::Namespace.new(config[:namespace], redis: connection) if config[:namespace]
          connection
        end
      end
    end

    def publish(channel, payload)
      if @fake
        fake_publishings.push(FakePublishing.new(channel, payload))
        return true
      end
      redis.rpush(
          'faye.messages',
          MultiJson.dump(
              channel: channel,
              payload: payload
          )
      )
    end

    def configured?; @connection || @_config end

    def publishings
      raise 'FayePublisher is not configured in fake! mode' unless @fake
      fake_publishings
    end

    def clear_publishings
      @fake_publishings.clear
    end

    private
    def fake_publishings
      @fake_publishings ||= []
    end
  end
end