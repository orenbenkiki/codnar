# Expand markdown text with some Codnar extensions.
module Codnar::Markdown

  # Process a Markdown String and return the resulting HTML.
  def self.md_to_html(markdown)
    return RDiscount.new(markdown).to_html
  end

end
