class Hash
  def slice(*keys)
    keys.each_with_object(self.class.new) { |k, hash| hash[k] = self[k] if has_key?(k) }
  end

  def symbolize_keys
    self.each_with_object(self.class.new) { |(k, v), hash|
      v = v.symbolize_keys if v.class.name == self.class.name
      hash[:"#{k}"] = v
    }
  end

  def stringify_keys
    self.each_with_object(self.class.new) { |(k, v), hash|
      v = v.stringify_keys if v.is_a?(self.class)
      hash["#{k}"] = v
    }
  end
end
