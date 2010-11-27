module Codnar

  # Run Codnar application with fake ARGV.
  module WithArgv

  protected

    def run_with_argv(argv)
      return Globals.without_changes do
        ARGV.replace(argv)
        yield
      end
    end

  end

end
