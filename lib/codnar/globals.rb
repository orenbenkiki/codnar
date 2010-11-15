module Codnar

  # Save and restore the global variables when running an application inside
  # a test.
  class Globals

    # Run some code without affecting the global state.
    def self.without_changes(&block)
      state = Globals.new
      begin
        return block.call
      ensure
        state.restore
      end
    end

    # Restore the relevant global variables.
    def restore
      $stdin = Globals.restore_file($stdin, @original_stdin)
      $stdout = Globals.restore_file($stdout, @original_stdout)
      $stderr = Globals.restore_file($stderr, @original_stderr)
      ARGV.replace(@original_argv)
    end

  protected

    # Take a snapshot of the relevant global variables.
    def initialize
      @original_stdin = $stdin
      @original_stdout = $stdout
      @original_stderr = $stderr
      @original_argv = ARGV.dup
    end

    # Restore a specific global file variable to its original state.
    def self.restore_file(current, original)
      current.close unless current == original
      return original
    end

  end

end
