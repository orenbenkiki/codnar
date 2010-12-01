module Codnar

  # Base class for Codnar applications.
  class Application

    # Create a Codnar application.
    def initialize(is_test = nil)
      @errors = Errors.new
      @is_test = !!is_test
      @configuration ||= {}
    end

    # Run the Codnar application, returning its status.
    def run(&block)
      parse_options
      block.call(@configuration) if block
      return print_errors
    rescue ExitException => exception
      return exception.status
    end

    # Execute a block with an overriden ARGV, typically for running an
    # application.
    def self.with_argv(argv)
      return Globals.without_changes do
        ARGV.replace(argv)
        yield
      end
    end

  protected

    # Parse the command line options of the program.
    def parse_options
      @options = GetOptions.new(%w(help version output=string error=string include|I=@string require=@string configuration=@string))
      redirect_files
      print_options
      load_modules
      merge_configurations
    end

    # Redirect standard output and error according to the parsed command line
    # options.
    def redirect_files
      $stdout = Application::redirect_file($stdout, @options.output)
      $stderr = Application::redirect_file($stderr, @options.error)
    end

    # Redirect a standard file.
    def self.redirect_file(default, file)
      return default if file.nil? || file == "-"
      FileUtils.mkdir_p(File.dirname(File.expand_path(file)))
      return File.open(file, "w")
    end

    # Print data about the program and exit according to the parsed command
    # line options.
    def print_options
      print_version if @options.version
      print_help if @options.help
    end

    # Print the current Codnar version.
    def print_version
      puts("#{$0}: Version: #{Codnar::VERSION}")
      exit(0)
    end

    # Print a short help message listing the available command line options.
    def print_help(&block)
      print_help_before_options
      print_standard_options
      print_help_after_options
      exit(0)
    end

    # Print the part of the help message before the standard options.
    def print_help_before_options
    end

    # Print the standard Codnar options.
    def print_standard_options
      print(<<-EOF.unindent)
        OPTIONS:

          -h, --help                           Print this help message and exit.
          -v, --version                        Print the version number (#{Codnar::VERSION}) and exit.
          -o, --output <path>|-                Redirect standard output to the <path>.
          -e, --error <path>|-                 Redirect standard error to the <path>.
          -I, --include <path>...              Add <path>(s) to Ruby's libs search path.
          -r, --require <path>...              Ruby require the code in the <path>(s).
          -c, --configuration <NAME>|<path>... Load named or disk file configuration(s).
      EOF
    end

    # Print the part of the help message after the standard options.
    def print_help_after_options
    end

    # Load all requested modules.
    def load_modules
      (@options.include || []).reverse.each do |path|
        $:.unshift(path)
      end
      (@options.require || []).each do |path|
        require path
      end
    end

    # Merge all the specified configuration data into one mapping.
    def merge_configurations
      configurations = @options.configuration || []
      @configuration = configurations.reduce(@configuration) do |configuration, name_or_path|
        named_configuration = Application.load_configuration(name_or_path)
        exit(1) unless named_configuration
        configuration.deep_merge(named_configuration)
      end
    end

    # Load a configuration either from the available builtin data or from a
    # disk file.
    def self.load_configuration(name_or_path)
      return YAML.load_file(name_or_path) if File.exist?(name_or_path)
      begin
        return Codnar::Configuration.const_get(name_or_path.upcase)
      rescue
        $stderr.puts("#{$0}: Configuration: #{name_or_path} is neither a disk file nor a known configuration")
      end
    end

    # Print all the collected errors.
    def print_errors
      @errors.each do |error|
        $stderr.puts(error)
      end
      return @errors.size
    end

    # Exit the application, unless we are running inside a test.
    def exit(status)
      Kernel.exit(status) unless @is_test
      raise ExitException.new(status)
    end

  end

  # Exception used to exit when running inside tests.
  class ExitException < Exception

    # The exit status.
    attr_reader :status

    # Create a new exception to indicate exiting the program with some status.
    def initialize(status)
      @status = status
    end

  end

end
