module Codnar

  # Weave application.
  class Weave < Application

    # Run the weaving Codnar application, returning its status.
    def run
      super { weave }
    end

  protected

    # Weave all the chunks together to a single HTML.
    def weave
      @configuration = Codnar::Configuration::WEAVE_INCLUDE if @configuration == {}
      weaver = Weaver.new(@errors, ARGV, @configuration)
      puts(weaver.weave("include"))
      weaver.collect_unused_chunk_errors
    end

    # Parse remaining command-line file arguments.
    def parse_arguments
      return if ARGV.size > 0
      $stderr.puts("#{$0}: No chunk files to weave")
      exit(1)
    end

    # Return the banner line of the help message.
    def banner
      return "codnar-weave - Weave documentation chunks to a single HTML."
    end

    # Return the name and description of any final command-line file arguments.
    def arguments
      return "MAIN-CHUNK ADDITIONAL-CHUNKS", "Chunk files to weave together."
    end

    # Return a short description of the program.
    def description
      print(<<-EOF.unindent)
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
