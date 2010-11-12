module Codnar

  # Expand RDoc text with some Codnar extensions.
  module RDoc

    # Convert a sequence of RDoc lines to HTML.
    def self.lines_to_html(lines)
      merged_line = lines[0]
      merged_line.kind = "html"
      merged_line.html = RDoc.rdoc_to_html(lines.map { |line| line.rdoc }.join("\n")).chomp
      return [ merged_line ]
    end

    # Process a RDoc String and return the resulting HTML.
    def self.rdoc_to_html(rdoc)
      return ::RDoc::Markup::ToHtml.new.convert(rdoc).chomp
    end

  end

end
