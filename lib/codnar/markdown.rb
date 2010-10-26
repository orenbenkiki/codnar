# Expand markdown text with some CodNar extensions.
module Codnar::Markdown

  # Process a markdown string and return the resulting HTML.
  def self.md_to_html(markdown)
    return RDiscount.new(markdown).to_html
  end

end
