module Mongoid
  module TirePlugin
    extend ActiveSupport::Concern
    included do
      after_save :tire_reindex
      after_destroy :tire_remove
    end

    private
    def tire_reindex
      SearchIndex.index(self)
    end
    def tire_remove
      SearchIndex.remove(self)
    end
  end
end