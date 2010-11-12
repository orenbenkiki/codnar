module Codnar

  # Expand Markdown text with some Codnar extensions.
  module Markdown

    # Convert a sequence of Markdown lines to HTML.
    def self.lines_to_html(lines)
      merged_line = lines[0]
      merged_line.kind = "html"
      merged_line.html = Markdown.md_to_html(lines.map { |line| line.markdown }.join("\n")).chomp
      return [ merged_line ]
    end

    # Process a Markdown String and return the resulting HTML.
    def self.md_to_html(markdown)
      return RDiscount.new(markdown).to_html
    end

  end

end
