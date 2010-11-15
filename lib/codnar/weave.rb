module Codnar

  # Weave application
  class Weave < Application

    # Create a Codnar application.
    def initialize(is_test = nil)
      super(is_test)
    end

    # Run the weaving Codnar application, returning its status.
    def run
      super { weave }
    end

  protected

    # Weave all the chunks together to a single HTML.
    def weave
      @configuration = Codnar::Configuration::INCLUDE if @configuration == {}
      weaver = Weaver.new(@errors, ARGV, @configuration)
      puts(weaver.weave(ARGV[0], "include"))
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

        Weave chunks in all chunk files to a single HTML that is printed to the
        output. The first file is expected to be the main documentation file
        that includes all the rest of the chunks via directives of the format:

          <script src="chunk-name" type="x-codnar/template-name"></script>

        Where the template-name is a key in the configuration, whose value is
        an ERB template for embedding the named chunk into the documentation.

        If no configuration is specified, the INCLUDE configuration is assumed.
        This configuration contains a single template named "include", which
        simply includes the named chunk into the generated HTML.
      EOF
    end

  end

end
