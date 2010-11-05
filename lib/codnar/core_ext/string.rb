# Extend the core String class.
class String

  # Process this String as Markdown and return the resulting HTML.
  def md_to_html
    return Codnar::Markdown::md_to_html(self)
  end

  # Convert this string to an identifier. This is a stable operation, so
  # anything that accept a name will also accept an identifier as well.
  def to_id
    return self.strip.gsub(/[^a-zA-Z0-9]+/, "-").downcase
  end

  # Strip away common indentation from the beginning of each line in this
  # string. By default, detects the indentation from the first line.
  def unindent(indentation = nil)
    indentation ||= sub(/[^ ].*/m, "")
    return gsub(/^#{indentation}/, "")
  end

end
