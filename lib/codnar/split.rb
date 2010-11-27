module Codnar

  # Split application.
  class Split < Application

    # Run the weaving Codnar application, returning its status.
    def run
      super { split }
    end

  protected

    # Parse the command line options of the program.
    def parse_options
      super
      case ARGV.size
      when 1 then return
      when 0 then $stderr.puts("#{$0}: No input file to split")
      else $stderr.puts("#{$0}: Too many input files to split")
      end
      exit(1)
    end

    # Split the specified input file into chunks.
    def split
      @configuration = Codnar::Configuration::SPLIT_HTML_DOCUMENTATION if @configuration == {}
      splitter = Splitter.new(@errors, @configuration)
      print(splitter.chunks(ARGV[0]).to_yaml)
    end

    # Print the part of the help message before the standard options.
    def print_help_before_options
      print(<<-EOF.unindent)
        codnar-split - Split documentation or code files to chunks.

      EOF
    end

    # Print the part of the help message after the standard options.
    def print_help_after_options
      print(<<-EOF.unindent)
        <path>                               Documentation or code file to split.

        DESCRIPTION:

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
