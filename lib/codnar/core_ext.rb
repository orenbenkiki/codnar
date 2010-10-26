# Extend the core string class.
class String

  # Process this string as markdown and return the resulting HTML.
  def md_to_html
    return Codnar::Markdown::md_to_html(self)
  end

end
