# Expand Markdown text with some Codnar extensions.
class Markdown

  # Process a Markdown String and return the resulting HTML.
  def self.to_html(markdown)
    return RDiscount.new(markdown).to_html
  end

end
