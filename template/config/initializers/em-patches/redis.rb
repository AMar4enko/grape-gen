require 'em-synchrony/em-hiredis'

unless defined?(REDIS_CONNECTION)
  module EventMachine
    module Hiredis
      class BaseClient
        def async_command(*args)
          old_method_missing(*args)
        end
      end
    end
  end
end