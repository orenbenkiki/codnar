module Codnar

  # Syntax highlight using Sunlight.
  class Sunlight

    # Convert a sequence of classified code lines to HTML using Sunlight syntax
    # highlighting. All we need to do is wrap the lines in an HTML +pre+
    # element with the correct class (<tt>sunlight-highlight-_syntax_</tt>).
    # The actual highlighting is done in the HTML DOM using Javascript.
    # Embedding this Javascript into the final HTML should be done separately.
    def self.lines_to_html(lines, syntax)
      return Formatter.lines_to_pre_html(lines, :class => "sunlight-highlight-#{syntax}")
    end

  end

end
