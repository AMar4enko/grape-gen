require 'tire/http/clients/faraday'

module Tire
  class ExternalLogger < Tire::Logger

    def initialize(logger)
      @logger = logger
    end

    def level
      @logger.level
    end

    def write(message)
      @logger.info message
    end

    def log_request(endpoint, params=nil, curl='')
      # 2001-02-12 18:20:42:32 [_search] (articles,users)
      #
      # curl -X POST ....
      #
      content  = "# #{time}"
      content += " [#{endpoint}]"
      content += " (#{params.inspect})" if params
      content += "\n#\n"
      content += curl
      content += "\n\n"
      write content
    end

    def log_response(status, took=nil, json='')
      # 2001-02-12 18:20:42:32 [200] (4 msec)
      #
      # {
      #   "took" : 4,
      #   "hits" : [...]
      #   ...
      # }
      #
      content  = "# #{time}"
      content += " [#{status}]"
      content += " (#{took} msec)" if took
      content += "\n#\n" unless json.to_s !~ /\S/
      json.to_s.each_line { |line| content += "# #{line}" } unless json.to_s !~ /\S/
      content += "\n\n"
      write content
    end

    def time
      Time.now.strftime('%Y-%m-%d %H:%M:%S:%L')
    end
  end
end


module Tire
  class Configuration
    def self.logger(logger = nil)
      return @logger = logger if logger
      @logger || nil
    end
  end
end

Tire.configure do
  url ApplicationSettings.elasticsearch.url
  logger Tire::ExternalLogger.new(Logging.logger[:elasticsearch])
end

