# Extend the core Hash class.
class Hash

  # Provide OStruct/JavaScript-like implicit .key and .key= methods.
  def method_missing(method, *arguments)
    method = method.to_s
    key = method.chomp('=')
    return method == key ? self[key] : self[key] = arguments[0]
  end

end
