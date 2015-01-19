module Faye
  module Publisher
    FakePublishing = Struct.new(:channel, :payload)

    class RedisPublisher
      def publish(*args)
        publishings << Faye::Publisher::FakePublishing.new(*args)
      end

      def clear_publishings
        @publishings.clear
      end

      def publishings
        @publishings ||= []
      end
    end
  end
end