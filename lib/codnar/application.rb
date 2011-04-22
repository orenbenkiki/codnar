module Codnar

  # Base class for Codnar applications.
  class Application < Olag::Application

    # Create a Codnar application.
    def initialize(is_test = nil)
      super(is_test)
      @configuration ||= {}
    end

    # Run the Codnar application, returning its status.
    def run(&block)
      super(@configuration, &block)
    end

  protected

    # Define Codnar application flags.
    def define_flags
      super
      define_include_flag
      define_require_flag
      define_merge_flag
      define_print_flag
    end

    # Return the application's version - that is, Codnar's version.
    def version
      return Codnar::VERSION
    end

    # Define a flag for collecting module load path directories.
    def define_include_flag
      @options.on("-I", "--include DIRECTORY", String, "Add directory to Ruby's load path.") do |path|
        $LOAD_PATH.unshift(path)
      end
    end

    # Define a flag for loading a Ruby module. This may be needed for
    # user-specified configurations to work.
    def define_require_flag
      @options.on("-r", "--require MODULE", String, "Load a Ruby module for user configurations.") do |path|
        begin
          require(path)
        rescue Exception => exception
          $stderr.puts("#{$0}: #{exception}")
          exit(1)
        end
      end
    end

    # Define a flag for applying (merging) a Codnar configuration.
    def define_merge_flag
      @options.on("-c", "--configuration NAME-or-FILE", String, "Apply a named or disk file configuration.") do |name_or_path|
        loaded_configuration = load_configuration(name_or_path)
        @configuration = @configuration.deep_merge(loaded_configuration)
      end
    end

    # Define a flag for printing the (merged) Codnar configuration.
    def define_print_flag
      @options.on("-p", "--print", "Print the merged configuration.") do |name_or_path|
        puts(@configuration.to_yaml)
      end
    end

    # Load a configuration either from the available builtin data or from a
    # disk file.
    def load_configuration(name_or_path)
      return YAML.load_file(name_or_path) if File.exist?(name_or_path)
      name, *arguments = name_or_path.split(':')
      value = configuration_value(name)
      value = value.call(*arguments) unless Hash === value
      return value
    end

    # Compute the value of a named built-in configuration.
    def configuration_value(name)
      begin
        value = Configuration.const_get(name.upcase)
        return value if value
      rescue
        value = nil
      end
      $stderr.puts("#{$0}: Configuration: #{name} is neither a disk file nor a known configuration")
      exit(1)
    end

  end

end
