module Codnar

  # Collect a list of errors.
  class Errors < Array

    # Create an empty errors collection.
    def initialize
      @path = nil
      @line = nil
    end

    # Associate all errors collected by a block with a specific disk file.
    def in_path(path, &block)
      prev_path, prev_line = @path, @line
      @path, @line = path, nil
      block.call
      @path, @line = prev_path, prev_line
    end

    # Set the line number for any errors collected from here on.
    def at_line(line)
      @line = line
    end

    # Add a single error to the collection, with automatic context annotation
    # (current disk file and line). Other methods (+push+, "+=" etc.) do not
    # automatically add the context annotation.
    def <<(message)
      push(annotate_error_message(message))
    end

  protected

    # Annotate an error message with the context (current file and line).
    def annotate_error_message(message)
      return "#{$0}: #{message}" unless @path
      return "#{$0}: #{message} in file: #{@path}" unless @line
      return "#{$0}: #{message} in file: #{@path} at line: #{@line}"
    end

  end

end
