# Collect a list of errors.
class Codnar::Errors < Array

  # Create an empty errors collection.
  def initialize
    @path = nil
    @line = nil
  end

  # Collect errors associated with a specific file.
  def in_path(path, &block)
    prev_path, prev_line = @path, @line
    @path, @line = path, nil
    block.call
    @path, @line = prev_path, prev_line
  end

  # Set the line number for the following errors.
  def at_line(line)
    @line = line
  end

  # Add a single error to the collection. This is the only way errors should be
  # added to the collection (do not use ".push", "+=", etc.).
  def <<(message)
    push(error_message(message))
  end

  # Format a complete error message.
  def error_message(message)
    return "#{$0}: #{message}" unless @path
    return "#{$0}: #{message} in file: #{@path}" unless @line
    return "#{$0}: #{message} in file: #{@path} at line: #{@line}"
  end

end
