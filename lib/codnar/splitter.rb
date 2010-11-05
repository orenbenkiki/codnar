module Codnar

  # Split disk files into chunks.
  class Splitter

    # Construct a splitter based on a configuration in the following structure:
    #
    #   syntax: <syntax>
    #
    # Where the syntax is passed as-is to (and expanded in-place by) a Scanner.
    def initialize(errors, configuration)
      @errors = errors
      @configuration = configuration
      @scanner = Scanner.new(errors, configuration.syntax)
    end

    # Split a disk file into chunks.
    def chunks(path)
      @lines = @scanner.lines(path)
      merge_similar_lines
      return file_chunk(path)
    end

    # A chunk for the whole file based on the single merged fragment.
    def file_chunk(path)
      raise "Multiple fragments are not implemented" unless @fragments.size == 1
      fragment = @fragments[0]
      raise "Non-html fragments are not implemented" unless fragment.kind == "html"
      return [ { 
        "name" => path,
        "locations" => [ { "file" => path, "line" => 1 } ],
        "html" => fragment.lines.map { |data| data.line }.join
      } ]
    end

  protected

    # Merge consequitive lines that have the same kind.
    def merge_similar_lines
      return [] if @lines.size == 0
      single_line_fragments = @lines.map { |line| Splitter.line_fragment(line) }
      @fragments = [ single_line_fragments.shift ]
      single_line_fragments.each do |next_fragment|
        merge_next_fragment(next_fragment)
      end
    end

    # Merge the next fragment into the fragments list.
    def merge_next_fragment(next_fragment)
      prev_fragment = @fragments.last
      raise "Multiple line kinds are not implemented" unless prev_fragment.kind == next_fragment.kind
      prev_fragment.lines += next_fragment.lines
    end

    # Construct a multi-line fragment for a single line
    def self.line_fragment(line)
      return {
        "kind" => line.delete("kind"),
        "lines" => [ line ]
      }
    end

  end

end
