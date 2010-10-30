# Extend the core String class.
class String

  # Process this String as Markdown and return the resulting HTML.
  def md_to_html
    return Codnar::Markdown::md_to_html(self)
  end

  # Convert the string to an identifier. This is a stable operation, so
  # anything that accept a name will also accept an identifier as well.
  def to_id
    return self.strip.gsub(/[^a-zA-Z0-9]+/, "-").downcase
  end

end
