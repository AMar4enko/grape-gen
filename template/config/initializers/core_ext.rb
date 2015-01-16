class DateTime
  alias_method :to_s, :iso8601
end

class Time
  alias_method :to_s, :iso8601
end

class Hash
  def pick(*keys)
    keys = keys.first if keys.first.kind_of? Array
    Hash[keys.zip(values_at(*keys))]
  end
end