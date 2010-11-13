# Extend the core Hash class.
class Hash

  # Provide OStruct/JavaScript-like implicit .key and .key= methods.
  def method_missing(method, *arguments)
    method = method.to_s
    key = method.chomp('=')
    return method == key ? self[key] : self[key] = arguments[0]
  end

  # Perform a deep merge with another hash.
  def deep_merge(hash)
    return merge(hash, &Hash.deep_merger)
  end

protected

  # Return a Hash merger that recursively merges nested hashes.
  def self.deep_merger
    return proc do |key, default, override|
      Hash === default && Hash === override ? default.deep_merge(override) : override
    end
  end

end
