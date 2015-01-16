require 'logging'

logger_config = YAML.load(File.read(ApplicationSettings.root('config/logging.yml')))[RACK_ENV.to_s].deep_symbolize_keys

apply_logger_config = ->(logger, config, buffering_options) do
  logger.level = config[:level] || :debug
  logger.additive = config[:additive] if logger.respond_to? 'additive='
  logger.add_appenders(
      (config[:appenders] || { default: {type: 'stdout'} }).map do |key, value|
        case value
          when String
            Logging.appenders.send(key, value, buffering_options)
          when Hash
            layout = value.delete(:layout)
            if layout
              if layout.kind_of? String
                value[:layout] = Logging.layouts.pattern(pattern: layout)
              else
                layout_type = layout.delete(:type) || :basic
                value[:layout] = Logging.layouts.send(layout_type, layout)
              end
            end

            Logging.appenders.send(value[:type] || key, logger.name, buffering_options.merge!(value).symbolize_keys!)
          else
            Logging.appenders.send(key, logger.name, buffering_options)
        end
      end
  )
end

buferring_options = [:auto_flushing, :immediate_at, :flush_period]
bufferring = Hash[buferring_options.zip(logger_config.values_at(*buferring_options))]
routes = logger_config.delete(:routes) || []

apply_logger_config.call(Logging.logger.root, logger_config, bufferring)

routes.each { |route, settings| apply_logger_config.call(Logging.logger[route], settings, bufferring) }