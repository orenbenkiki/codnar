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
      convert_fragments_to_html
      return file_chunk(path)
    end

    # A chunk for the whole file based on the single merged fragment.
    def file_chunk(path)
      raise "Multiple fragments are not implemented" if @fragments.size > 1
      fragment = @fragments[0] || { "kind" => "html", "lines" => [ { "html" => "" } ] }
      raise "Non-html fragments are not implemented" unless fragment.kind == "html"
      return [ { 
        "name" => path,
        "locations" => [ { "file" => path, "line" => 1 } ],
        "html" => fragment.lines.map { |line| line.html }.join("\n")
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
      Splitter.merge_similar_fragments(prev_fragment, next_fragment)
    end

    # Merge two consequtive fragments with the same kind of lines.
    def self.merge_similar_fragments(prev_fragment, next_fragment)
      prev_fragment.lines += next_fragment.lines
      prev_fragment.location.lines += next_fragment.location.lines
    end

    # Construct a multi-line fragment for a single line.
    def self.line_fragment(line)
      return {
        "kind" => line.delete("kind"),
        "location" => line.location.merge({ "lines" => 1 }),
        "lines" => [ line ]
      }
    end

    # Convert all fragments to HTML.
    def convert_fragments_to_html
      @fragments.map! do |fragment|
        if fragment.kind == "html"
          fragment
        else
          convert_fragment_to_html(fragment)
        end
      end
      @fragments.compact!
    end

    # Convert a single fragment to HTML.
    def convert_fragment_to_html(fragment)
      process = @configuration.process[fragment.kind]
      return eval process if process
      unknown_fragment_kind_error(fragment)
      return nil
    end

    # Complain about a fragment with an unknown kind.
    def unknown_fragment_kind_error(fragment)
      location = fragment.location
      @errors.in_path(location.file) do
        @errors.at_line(location.line)
        @errors << "Don't know how to process fragment kind: #{fragment.kind}"
      end
    end

  end

end
