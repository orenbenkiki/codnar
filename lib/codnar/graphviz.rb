module Codnar

  # Generate diagrams using GraphViz.
  class GraphViz

    # Convert a string containing a GraphViz diagram into SVG suitable for
    # embedding into the HTML documentation. We pre-process the diagram using
    # M4 to allow cutting down on the boilerplate (repeating the same styles in
    # many nodes etc.). This should not be harmful for diagrams that do not use
    # M4 commands.
    def self.to_html(diagram)
      stdin, stdout, stderr = Open3.popen3("m4 | dot -Tsvg")
      write_diagram(stdin, diagram)
      check_for_errors(stderr)
      return clean_output(stdout)
    end

  protected

    # Send the diagram to the commands pipe.
    def self.write_diagram(stdin, diagram)
      stdin.write(diagram)
      stdin.close
    end

    # Ensure we got no processing errors from either m4 or dot. If we did,
    # raise them, and they will be handled by the formatter wrapping code.
    def self.check_for_errors(stderr)
      errors = stderr.read
      raise errors.sub(/Error: <stdin>:\d+: /, "") if errors != ""
    end

    # Clean the SVG we got to make it suitable for embedding in HTML.
    def self.clean_output(stdout)
      return stdout.read.sub(/.*<svg/m, "<svg").gsub(/\r/, "")
    end

  end

end
