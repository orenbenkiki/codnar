# Extend the core Hash class.
class Hash

  # Obtain a deep clone which shares nothing with this hash.
  def deep_clone
    return YAML.load(to_yaml)
  end

  # {{{ Deep merge

  # Perform a deep merge with another hash.
  def deep_merge(hash)
    return merge(hash, &Hash::method("deep_merger"))
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

  # If the overriding data array contains an empty array element ("[]"), it is
  # replaced by the default data array being overriden.
  def self.deep_merge_arrays(default, override)
    embed_index = override.find_index([])
    return override unless embed_index
    override = override.dup
    override[embed_index..embed_index] = default
    return override
  end

  # }}}

end
