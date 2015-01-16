require 'tire/http/clients/faraday'

Tire.configure do
  Tire::HTTP::Client::Faraday.faraday_middleware = Proc.new do |builder|
    builder.adapter :em_synchrony
  end
  client Tire::HTTP::Client::Faraday
end