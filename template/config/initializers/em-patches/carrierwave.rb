require 'em-synchrony'
require 'carrierwave/processing/mini_magick'

module CarrierWave
  module MiniMagick
    alias_method :old_manipulate!, :manipulate!
    def manipulate!(&block)
      EventMachine::Synchrony.defer do
        old_manipulate!(&block)
      end
    end
  end
end