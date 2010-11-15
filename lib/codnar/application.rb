module Codnar

  # Base class for Codnar applications.
  class Application

    # Create a Codnar application.
    def initialize(is_test = nil)
      @is_test = !!is_test
    end

    # Run the Codnar application, returning its status.
    def run
      parse_options
      return 0
    rescue ExitException => exception
      return exception.status
    end

  protected

    # Parse the command line options of the program.
    def parse_options(additional_options = [])
      @options = GetOptions.new(%w(help version output=s error=s) + additional_options)
      redirect_files
      print_options
    end

    # Redirect standard output and error according to the parsed command line
    # options.
    def redirect_files
      $stdout = Application::redirect_file($stdout, @options[:output])
      $stderr = Application::redirect_file($stderr, @options[:error])
    end

    # Redirect a standard file.
    def self.redirect_file(default, file)
      return default if file.nil? || file == "-"
      return File.open(file, "w")
    end

    # Print data about the program and exit according to the parsed command
    # line options.
    def print_options
      print_version if @options[:version]
      print_help if @options[:help]
    end

    # Print the current Codnar version.
    def print_version
      puts("#{$0}: Version: #{Codnar::VERSION}")
      exit(0)
    end

    # The standard application options.
    HELP = <<-EOF.unindent
      -h, --help          Print this help message and exit.
      -v, --version       Print the version number (#{Codnar::VERSION}) and exit.
      -o, --output <file> Redirect standard output to the <file>.
      -e, --error <file>  Redirect standard error to the <file>.
    EOF

    # Print a short help message listing the available command line options.
    def print_help
      print(HELP)
      exit(0)
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
