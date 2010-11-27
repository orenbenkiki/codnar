module Codnar

  # Weave application.
  class Weave < Application

    # Run the weaving Codnar application, returning its status.
    def run
      super { weave }
    end

  protected

    # Parse the command line options of the program.
    def parse_options
      super
      return if ARGV.size > 0
      $stderr.puts("#{$0}: No chunk files to weave")
      exit(1)
    end

    # Weave all the chunks together to a single HTML.
    def weave
      @configuration = Codnar::Configuration::WEAVE_INCLUDE if @configuration == {}
      weaver = Weaver.new(@errors, ARGV, @configuration)
      puts(weaver.weave(ARGV[0], "include"))
      weaver.collect_unused_chunk_errors
    end

    # Print the part of the help message before the standard options.
    def print_help_before_options
      print(<<-EOF.unindent)
        codnar-weave - Weave documentation chunks to a single HTML.

      EOF
    end

    # Print the part of the help message after the standard options.
    def print_help_after_options
      print(<<-EOF.unindent)
        <main-path> <chunks-path>...         Chunk files to weave together.

        DESCRIPTION:

          Weave chunks in all chunk files (from codnar-split) to a single HTML that is
          printed to the output. The first file is the main documentation file that is
          expected to include all the rest of the chunks via directives of the format:

            <embed src="chunk-name" type="x-codnar/template-name"></embed>

          Where the template-name is a key in the configuration, whose value is an ERB
          template for embedding the named chunk into the documentation.

          If no configuration is specified, the WEAVE_INCLUDE configuration is assumed.
          This configuration contains a single template named "include", which simply
          includes the named chunk into the generated HTML.
      EOF
    end

  end

end
