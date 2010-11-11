module Codnar

  # Format chunks into HTML.
  class Formatter

    # Construct a formatter based on a mapping from a line kind to a Ruby
    # expression that converts an array of lines of that kind into an array of
    # lines of another kind.
    def initialize(errors, formatters)
      @errors = errors
      @formatters = { "html" => "Formatter.merge_html_lines(lines)" }.merge(formatters)
    end

    # Process lines of arbitrary kinds until we obtain a single complete HTML.
    def lines_to_html(lines)
      until Formatter.single_html_line?(lines)
        lines = Grouper.lines_to_groups(lines).map { |group| process_lines_group(group) }.flatten
      end
      return lines.last.andand.html.to_s
    end

  protected

    # Check whether we have finally got a single HTML "line" for the whole
    # lines sequence.
    def self.single_html_line?(lines)
      return lines.size <= 1 && lines[0].andand.kind == "html"
    end

    # Perform one pass of processing toward HTML on a group of lines with the
    # same kind.
    def process_lines_group(lines)
      kind = lines.last.kind
      formatter = @formatters[kind] ||= missing_formatter(kind)
      begin
        return eval formatter
      rescue
        return failed_formatter(lines, formatter, $!)
      end
    end

    # Return a formatter for a kind that doesn't have one already specified.
    def missing_formatter(kind)
      @errors << "No formatter specified for lines of kind: #{kind}"
      return "Formatter.lines_to_pre_html(lines)"
    end

    # Merge a group of consecutive HTML lines into a group with a single HTML
    # "line". This is the default "formatter" for HTML lines.
    def self.merge_html_lines(lines)
      merged_line = lines[0]
      merged_line.html = lines.map { |line| line.html }.join("\n")
      return [ merged_line ]
    end

    # Format lines into HTML using a pre element. This is the default formatter
    # for lines of unknown kinds.
    def self.lines_to_pre_html(lines)
      merged_line = lines[0]
      merged_line.kind = "html"
      merged_line.html = "<pre>" + lines.map { |line| CGI::escapeHTML(line.line) }.join("\n") + "</pre>"
      return [ merged_line ]
    end

    # Format lines if the specified formatter failed.
    def failed_formatter(lines, formatter, exception)
      @errors << "Formatter: #{formatter} for lines of kind: #{lines.last.kind} failed with exception: #{exception}"
      return Formatter.lines_to_pre_html(lines)
    end

  end

end
