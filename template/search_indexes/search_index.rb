class SearchIndex < Tire::Index
  NoIndexForModel = Class.new(StandardError)

  def initialize(name)
    super("#{RACK_ENV}_#{name}")
  end

  def type
    @_type ||= model.to_s.underscore.gsub('/','_')
  end

  def model
    "Models::#{self.class.name.chomp('Index')}".constantize
  end

  class << self
    def create_indexes!
      indexes.each do |index|
        index.delete
        index.create
      end
    end

    def index(instance)
      index = index_by_klass(instance.class)
      index.store(instance)
    rescue NoIndexForModel
      # ignored
    end

    def remove(instance)
      index = index_by_klass(instance.class)
      index.remove(instance)
    end

    def reindex!
      indexes.each do |index_instance|
        index_instance.delete
        index_instance.create
        index_instance.model.all.each do |model_instance|
          index(model_instance)
        end
      end
    end

    private
    def index_by_klass(model_klass)
      @_cache ||= {}
      @_cache[model_klass] and (return @_cache[model_klass])
      idx = indexes.find{|idx| idx.model == model_klass}
      raise NoIndexForModel unless idx
      @_cache[model_klass] = idx
      idx
    end

    def indexes
      @_indexes ||= ObjectSpace.each_object(Class).select{ |klass| klass < self }.map(&:new)
    end
  end
end