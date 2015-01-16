require_relative 'warden/token_strategy'

module Faye
  class AuthExtension
    def initialize(server_secret)
      @server_secret = server_secret
    end

    def subscribe_authorized?(env, channel)
      case channel
        when
          '/user/registered', '/time'
          return true
        when %r{^/user/([0-9]+)}
          strategy = TokenStrategy.new(env)
          return false unless strategy.valid? and (strategy.authenticate! == :success)
          strategy.user.id == $1.to_i
        else
          false
      end
    end

    def incoming(message, callback)
      # Let non-subscribe messages through
      if message['ext'] && (message['ext']['faye_server_secret'] == @server_secret)
        message.delete('ext')
        callback.call(message)
        return message
      end

      unless message['channel'] =~ %r{^/meta}
        if message['ext'].nil? || (message['ext']['faye_server_secret'] != @server_secret)
          message['error'] = 'Unauthorized'
        end

        callback.call(message)
        return message
      end

      unless message['channel'] == '/meta/subscribe'
        callback.call(message)
        return message
      end

      # Get subscribed channel and auth token
      subscription = message['subscription']

      message['ext'] ||= {}

      env = {
          'HTTP_X_AUTHORIZE' => message['ext']['X-Authorize']
      }

      message['error'] = 'Unauthorized' unless subscribe_authorized?(Hashie::Mash.new(env), subscription)

      callback.call(message)

      message
    end
  end
end