module Codnar

  module Rake

    # A Rake task for weaving chunks to a single HTML.
    class WeaveTask < ::Rake::TaskLib

      # Create a Rake task for weaving chunks to a single HTML. The root source
      # file is expected to embed all the chunks into the output HTML. The
      # chunks are loaded from the results of all the previous created
      # SplitTask-s.
      def initialize(root, configurations, output = "codnar.html")
        @root = Rake.chunks_dir + "/" + root
        @output = output
        @configurations = configurations
        define_tasks
      end

    protected

      # Define the tasks for weaving the chunks to a single HTML.
      def define_tasks
        define_weave_task
        connect_common_tasks
      end

      # Define the actual task for weaving the chunks to a single HTML.
      def define_weave_task
        desc "Weave chunks into HTML" unless ::Rake.application.last_comment
        ::Rake::Task.define_task("codnar_weave" => @output)
        ::Rake::FileTask.define_task(@output => Rake.chunk_files + Rake.configuration_files(@configurations)) do
          run_weave_application
        end
      end

      # Run the Weave application for a single source file.
      def run_weave_application
        options = Rake.application_options(@output, @configurations)
        options << @root
        options += Rake.chunk_files.reject { |chunk| chunk == @root }
        status = Application.with_argv(options) { Weave.new.run }
        raise "Codnar weave errors" unless status == 0
      end

      # Connect the task for cleaning up after weaving (+clobber_codnar+) to the
      # common task of cleaning up everything (+clobber+).
      def connect_common_tasks
        desc "Build the code narrative HTML"
        ::Rake::Task.define_task(:codnar => "codnar_weave")
        desc "Remove woven HTML documentation"
        ::Rake::Task.define_task("clobber_codnar") { rm_rf(@output) }
        ::Rake::Task.define_task(:clobber => "clobber_codnar")
      end

    end

  end

end
