# Extend the core String class.
class String

  # Process this String as Markdown and return the resulting HTML.
  def md_to_html
    return Codnar::Markdown::md_to_html(self)
  end

end
