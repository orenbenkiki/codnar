module Codnar

  # Split application.
  class Split < Application

    # Run the weaving Codnar application, returning its status.
    def run
      super { split }
    end

  protected

    # Split the specified input file into chunks.
    def split
      @configuration = Codnar::Configuration::SPLIT_HTML_DOCUMENTATION if @configuration == {}
      splitter = Splitter.new(@errors, @configuration)
      print(splitter.chunks(ARGV[0]).to_yaml)
    end

    # Parse remaining command-line file arguments.
    def parse_arguments
      expect_exactly(1, "files to split")
    end

    # Return the banner line of the help message.
    def banner
      return "codnar-split - Split documentation or code files to chunks."
    end

    # Return the name and description of any final command-line file arguments.
    def arguments
      return "FILE", "Documentation or code file to split."
    end

    # Return a short description of the program.
    def description
      return <<-EOF.unindent
        Split the documentation of file into chunks that are printed in YAML format to
        the output (to be read by codnar-weave). Many file formats can be split
        depending on the specified configuration. The default configuration is called
        SPLIT_HTML_DOCUMENTATION, and it preserves the whole file as a single formatted
        HTML documentation chunk. This isn't very useful.

        The configuration needs to specify a set of line classification patterns,
        parsing states and pattern-based transitions between them, the initial state,
        and expressions for formatting classified lines to HTML. See the Codnar
        documentation for details.
      EOF
    end

  end

end
