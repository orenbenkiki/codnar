# Extend the core String class.
class String

  # Convert this String to an identifier. This is a stable operation, so
  # anything that accept a name will also accept an identifier as well.
  def to_id
    return self.strip.gsub(/[^a-zA-Z0-9]+/, "-").downcase
  end

  # Strip away common indentation from the beginning of each line in this
  # String. By default, detects the indentation from the first line. This can
  # be overriden to the exact (String) indentation to strip, or to the (Fixnum)
  # number of spaces the first line is further-indented from the rest of the
  # text.
  def unindent(unindentation = 0)
    unindentation = " " * (indentation.length - unindentation) if Fixnum === unindentation
    return gsub(/^#{unindentation}/, "")
  end

  # Extract the indentation from the beginning of this String.
  def indentation
    return sub(/[^ ].*$/m, "")
  end

end
