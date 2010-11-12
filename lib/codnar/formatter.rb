module Codnar

  # Format chunks into HTML.
  class Formatter

    # Construct a Formatter based on a mapping from a line kind, to a Ruby
    # expression, that converts an array of lines of that kind, into an array
    # of lines of another kind. This expression is simply eval-ed, and is
    # expected to make use of a variable called "lines" that contains an array
    # of classified lines, as produced by a Scanner. The result of evaluating
    # the expressions is expected to be an array of any number of classified
    # lines of any kind.
    #
    # Formatting repeatedly applies these formatting expressions, until the
    # result is an array containing a single line, which has the kind "html"
    # and whose html field contains the unified final HTML presentation of the
    # original lines. In each processing round, all consecutive lines of the
    # same kind are formated together. This allows for properly formating line
    # kinds that use a multi-line notation such as Markdown.
    #
    # The default formatting expression for the kind "html" simply joins all
    # the html fields of all the lines into a single html, and returns a single
    # "line" containing this joined HTML. All other line kinds need to have a
    # formatting expression explicitly specified in the formatters mapping.
    #
    # If no formatting expression is specified for some line kind, an error is
    # reported and the lines are wrapped in a pre HTML element with a
    # "missing_formatter" class. Similarly, if a formatting expression fails
    # (raises an exception), an error is reported and the lines are wrapped in
    # a pre HTML element with a "failed_formatter" class.
    def initialize(errors, formatters)
      @errors = errors
      @formatters = { "html" => "Formatter.merge_html_lines(lines)" }.merge(formatters)
    end

    # Repeatedly process an array of classified lines of arbitrary kinds until
    # we obtain a single "line" containing a unified final HTML presentation of
    # the original lines.
    def lines_to_html(lines)
      until Formatter.single_html_line?(lines)
        lines = Grouper.lines_to_groups(lines).map { |group| process_lines_group(group) }.flatten
      end
      return lines.last.andand.payload.to_s
    end

  protected

    # Check whether we have finally got a single HTML "line" for the whole
    # lines sequence.
    def self.single_html_line?(lines)
      return lines.size <= 1 && lines[0].andand.kind == "html"
    end

    # Perform one pass of processing toward HTML on a group of consecutive
    # lines with the same kind.
    def process_lines_group(lines)
      kind = lines.last.kind
      formatter = @formatters[kind] ||= missing_formatter(kind)
      begin
        return eval formatter
      rescue
        return failed_formatter(lines, formatter, $!)
      end
    end

    # Return an expression for formatting lines of a kind that doesn't have one
    # already specified.
    def missing_formatter(kind)
      @errors << "No formatter specified for lines of kind: #{kind}"
      return "Formatter.lines_to_pre_html(lines, :class => :missing_formatter)"
    end

    # Format lines as HTML if the specified formatting expression failed.
    def failed_formatter(lines, formatter, exception)
      @errors << "Formatter: #{formatter} for lines of kind: #{lines.last.kind} failed with exception: #{exception}"
      return Formatter.lines_to_pre_html(lines, :class => :failed_formatter)
    end

    # Merge a group of consecutive HTML lines into a group with a single HTML
    # "line". This is the default "formatter" for HTML lines.
    def self.merge_html_lines(lines)
      merged_line = lines[0]
      merged_line.payload = lines.map { |line| line.payload }.join("\n")
      return [ merged_line ]
    end

    # Format lines into HTML using a pre element with optional attributes. This
    # is the default formatter for lines of unknown kinds.
    def self.lines_to_pre_html(lines, attributes = {})
      merged_line = lines[0]
      merged_line.kind = "html"
      merged_line.payload = "<pre" + Formatter.html_attributes(attributes) + ">\n" \
                          + lines.map { |line| CGI.escapeHTML(line.payload) + "\n" }.join \
                          + "</pre>"
      return [ merged_line ]
    end

    # Convert an attribute mapping to HTML.
    def self.html_attributes(attributes)
      return attributes == {} ? "" : " " + attributes.map { |name, value| "#{name}='#{CGI.escapeHTML(value.to_s)}'" }.join(" ")
    end

    # Format lines that indicate a nested chunk to HTML.
    def self.nested_chunk_lines_to_html(lines)
      return lines.map do |line|
        (line = line.dup).kind = "html"
        chunk_name = line.payload
        line.payload = "<pre class='nested_chunk'>\n" \
                     + "#{line.indentation}<a href='#{chunk_name.to_id}'>#{CGI.escapeHTML(chunk_name)}</a>\n" \
                     + "</pre>"
        line
      end
    end

    # Convert a sequence of marked-up lines to HTML.
    def self.markup_to_html(lines, klass)
      klass = Kernel.const_get(klass) if String === klass
      kind = (merged_line = lines[0]).kind
      merged_line.kind = "html"
      merged_line.payload = "<div class='#{kind}'>\n" \
                          + klass.to_html(lines.map { |line| line.payload + "\n" }.join) \
                          + "</div>"
      return [ merged_line ]
    end

  end

end
