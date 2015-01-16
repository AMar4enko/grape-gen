require_relative 'config/boot_faye'

Faye::WebSocket.load_adapter('thin')
Faye.logger = Logging.logger[:faye]

class ServerClientSecretAuth
  def initialize(secret)
    @secret = secret
  end
  def outgoing(message, callback)
    if message['channel'] =~ %r{^/meta}
      callback.(message)
      return message
    end

    message['ext'] ||= {}
    # Set the auth token
    message['ext']['faye_server_secret'] = @secret

    # Carry on and send the message to the server
    callback.(message)
    message
  end
end

faye_adapter_settings = {
    mount: '/', timeout: 180,
    extensions: [Faye::AuthExtension.new(ApplicationSettings.faye.server_secret)]
}

faye_adapter_settings[:engine] = {
    type: Faye::Redis,
    uri: ApplicationSettings.faye.redis.url
}


bayeux = Faye::RackAdapter.new(faye_adapter_settings)

faye_client = bayeux.get_client
faye_client.add_extension(ServerClientSecretAuth.new(ApplicationSettings.faye.server_secret))

EventMachine.schedule do
  redis_connection = EventMachine::Hiredis.connect(ApplicationSettings.faye.redis[:url])
  redis_connection = Redis::Namespace.new(ApplicationSettings.faye.redis[:namespace], redis: redis_connection) if ApplicationSettings.faye.redis[:namespace]

  pop = Proc.new do
    redis_connection.blpop('faye.messages',1).callback do |list, msg|
      faye_client.publish(*MultiJson.load(msg).values_at('channel','payload')) if msg
      EventMachine.next_tick(pop)
    end
  end
  EventMachine.next_tick(pop)
end

run bayeux