module Codnar

  # Extend the CodeRay module.
  module CodeRay

    # Convert a sequence of classified code lines to HTML using CodeRay syntax
    # highlighting. The options control the way CodeRay behaves (e.g., <tt>:css
    # => :class</tt>).
    def self.lines_to_html(lines, syntax, options = {})
      return Formatter.merge_lines(lines, "html") do |payload|
        ::CodeRay.scan(payload, syntax).div(options).chomp
      end
    end

  end

end
