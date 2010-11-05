# Expand markdown text with some Codnar extensions.
module Codnar::Markdown

  # Process a Markdown String and return the resulting HTML.
  def self.md_to_html(markdown)
    return RDiscount.new(markdown).to_html
  end

  # Convert a markdown fragment to an HTML fragment.
  def self.fragment_to_html(fragment)
    fragment.kind = "html"
    fragment.lines = [ {
      "kind" => "html",
      "html" => fragment.lines.map { |data| data.line }.join.md_to_html.chomp
    } ]
    return fragment
  end

end
