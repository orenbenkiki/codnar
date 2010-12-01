# Extend the core Hash class.
class Hash

  # Provide OStruct/JavaScript-like implicit .key and .key= methods.
  def method_missing(method, *arguments)
    method = method.to_s
    key = method.chomp("=")
    return method == key ? self[key] : self[key] = arguments[0]
  end

  # Perform a deep merge with another hash.
  def deep_merge(hash)
    return merge(hash, &Hash::method("deep_merger"))
  end

  # Obtain a deep clone which shares nothing with this hash.
  def deep_clone
    return YAML.load(to_yaml)
  end

protected

  # Return a Hash merger that recursively merges nested hashes.
  def self.deep_merger(key, default, override)
    if Hash === default && Hash === override
      default.deep_merge(override)
    elsif Array === default && Array === override
      Hash.deep_merge_arrays(default, override)
    else
      override
    end
  end

  # If the override has a nil element, it is replaced by the default it is
  # overriding.
  def self.deep_merge_arrays(default, override)
    embed_index = override.find_index([])
    return override unless embed_index
    override = override.dup
    override[embed_index..embed_index] = default
    return override
  end

end
