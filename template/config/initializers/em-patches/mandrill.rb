# Patch mandrill API to play ball with EventMachine
module Mandrill
  class API
    def initialize(apikey=nil, debug=false)
      @host = 'https://mandrillapp.com'
      @path = '/api/1.0/'

      @debug = debug

      unless apikey
        if ENV['MANDRILL_APIKEY']
          apikey = ENV['MANDRILL_APIKEY']
        else
          apikey = read_configs
        end
      end

      raise Error, 'You must provide a Mandrill API key' unless apikey
      @apikey = apikey
    end

    def call(url, params={})
      defer = EventMachine::DefaultDeferrable.new
      params[:key] = @apikey
      params = JSON.generate(params)
      http = Mandrill::API.request.get(path: "#{@path}#{url}.json", headers: {'Content-Type' => 'application/json'}, body: params, keepalive: true)
      http.callback do |r|
        cast_error(r.response) if r.response_header.status != 200
        defer.succeed(JSON.parse(r.response))
      end

      http.errback do |r|
        raise Mandrill::ServiceUnavailableError.new
      end

      EventMachine::Synchrony.sync defer
    end

    class << self
      def request
        EventMachine::HttpRequest.new('https://mandrillapp.com/api/1.0/')
      end
    end
  end
end