# Extend the core String class.
class String

  # Convert this String to an identifier. This is a stable operation, so
  # anything that accept a name will also accept an identifier as well.
  def to_id
    return self.strip.gsub(/[^a-zA-Z0-9]+/, "-").downcase
  end

  # Strip away common indentation from the beginning of each line in this
  # String. By default, detects the indentation from the first line.
  def unindent(indentation = nil)
    indentation ||= sub(/[^ ].*/m, "")
    return gsub(/^#{indentation}/, "")
  end

end
