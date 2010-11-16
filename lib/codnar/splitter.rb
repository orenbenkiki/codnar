module Codnar

  # Split disk files into chunks.
  class Splitter

    # Construct a splitter based on a configuration in the following structure:
    #
    #   syntax: <syntax>
    #   formatters:
    #     <kind>: <expression>
    #
    # Where the syntax is passed as-is to (and expanded in-place by) a Scanner,
    # and the formatters are passed as-is to a Formatter to convert the chunk's
    # classified lines into HTML.
    def initialize(errors, configuration)
      @errors = errors
      @configuration = configuration
      @scanner = Scanner.new(errors, configuration.syntax)
      @formatter = Formatter.new(errors, configuration.formatters)
    end

    # Split a disk file into HTML chunks.
    def chunks(path)
      lines = @scanner.lines(path)
      chunks = Merger.chunks(@errors, path, lines)
      chunks.each { |chunk| chunk.html = @formatter.lines_to_html(chunk.delete("lines")) }
      return chunks
    end

  end

end
