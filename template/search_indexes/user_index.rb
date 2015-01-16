class UserIndex < SearchIndex
  def initialize
    super('users')
  end

  def create
    super(
        mappings: {
          type => {
            # Your mappings here
          }
        }
    )
  end

  def store(instance)
    index_data = instance.attributes
    super(index_data)
  end
end