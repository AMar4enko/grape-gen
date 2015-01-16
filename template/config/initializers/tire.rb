require 'tire/http/clients/faraday'

Tire.configure do
  url ApplicationSettings.elasticsearch.url
  logger Logging.logger[:elasticsearch]
end