require 'logging'
require 'settingslogic'
Logging.init :devel, :debug, :response, :info, :warn, :error, :fatal

class ApplicationSettings < Settingslogic
  namespace RACK_ENV.to_s
  class << self
    def root=(value)
      instance[:app_root] = value
    end

    def root(*path)
      return File.expand_path(File.join(path), instance[:app_root]) if path
      instance[:app_root]
    end

    # @return [String]
    def api_absolute_url(uri)
      "#{api_root}#{uri}"
    end

    # @return [String]
  end
end