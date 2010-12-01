module Codnar

  module Rake

    # A Rake task for splitting source files to chunks.
    class SplitTask < ::Rake::TaskLib

      # Create a new Rake task for splitting source files to chunks. Each of
      # the specified disk files is split using the specified set of
      # configurations.
      def initialize(paths, configurations)
        @configurations = configurations
        paths.each do |path|
          @path = path
          define_tasks
        end
      end

    protected

      # Define the tasks for splitting a single source file to chunks.
      def define_tasks
        @output = Rake.chunks_dir + "/" + @path
        define_split_file_task
        SplitTask.define_common_tasks
        connect_common_tasks
      end

      # Define the actual task for splitting the source file.
      def define_split_file_task
        ::Rake::FileTask.define_task(@output => [ @path ] + Rake.configuration_files(@configurations)) do
          run_split_application
        end
      end

      # Run the Split application for a single source file.
      def run_split_application
        options = Rake.application_options(@output, @configurations)
        options << @path
        Application.with_argv(options) { Split.new.run }
      end

      # Connect the task for splitting a single source file to the common task
      # for splitting all source files.
      def connect_common_tasks
        ::Rake::Task.define_task("codnar_split" => @output)
        Rake::chunk_files << @output
      end

      # Define common Rake split tasks. This method may be invoked several
      # times, only the first invocation actually defined the tasks. The common
      # tasks are codnar_split (for splitting all the source files) and
      # clean_codnar (for getting rid of the chunks directory).
      def self.define_common_tasks
        @defined_common_tasks ||= SplitTask.create_common_tasks
      end

      # Actually create common Rake split tasks.
      def self.create_common_tasks
        desc "Split all files into chunks"
        ::Rake::Task.define_task("codnar_split")
        desc "Clean all split chunks"
        ::Rake::Task.define_task("clean_codnar") { rm_rf(Rake.chunks_dir) }
        ::Rake::Task.define_task(:clean => "clean_codnar")
      end

    end

  end

end
