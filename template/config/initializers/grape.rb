module Grape
  module Formatter
    module Json
      class << self
        def call(object, env)
          MultiJson.dump(object)
        end
      end
    end
  end
end