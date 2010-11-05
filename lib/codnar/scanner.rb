module Codnar

  # Scan a file into classified lines.
  class Scanner

    # Construct a scanner based on a syntax in the following structure:
    #
    #   patterns:
    #     <name>:
    #       name: <name>
    #       regexp: <regexp>
    #       groups:
    #       - <name>
    #   states:
    #     <name>:
    #       name: <name>
    #       kind: <kind>
    #       transitions:
    #       - pattern: <pattern>
    #         next_state: <state>
    #   start_state: <state>
    #
    # To allow for cleaner YAML files to specify the syntax, the following
    # shorthands are supported:
    #
    # - A pattern or state reference can be presented by the string pattern or
    #   state name.
    # - The name field of a state or pattern can be ommitted. If specified, it
    #   must be identical to the key in the states or patterns mapping.
    # - The kind field of a state can be ommitted; by default it is assumed to
    #   be identical to the state name.
    # - A regexp can be presented by a plain string.
    # - The pattern groups field can be ommitted or contain null if it is
    #   empty.
    #
    # When the Scanner is constructed, the syntax object is modified in place
    # to expand all the above shorthands, collecting any invalid references
    # and/or regexps errors.
    def initialize(errors, syntax)
      @errors = errors
      @syntax = syntax
      @syntax.patterns.each { |name, pattern| expand_pattern_shorthands(name, pattern) }
      @syntax.states.each { |name, state| expand_state_shorthands(name, state) }
      @syntax.start_state = resolve_start_state
    end

    # Scan a disk file into classified lines in the following format (where the
    # groups contain the text extracted by the matching pattern):
    #
    #   - kind: <kind>
    #     line: <text>
    #     <group>: <text>
    #
    # If at some state, a line does not match any pattern, the scanner will
    # collect an error message for it and classify the line as follows:
    #
    #   - kind: error
    #     line: <text>
    #     state: <name>
    def lines(path)
      @path = path
      @lines = []
      @state = @syntax.start_state
      @errors.in_path(path) { scan_path }
      return @lines
    end

  protected

    # Expand all the shorthands used in the pattern.
    def expand_pattern_shorthands(name, pattern)
      fill_name(name, pattern, "Pattern")
      pattern.groups ||= []
      begin
        pattern_regexp = pattern.regexp
        pattern.regexp = Regexp.new(pattern_regexp) unless Regexp === pattern_regexp
      rescue
        @errors << "Invalid pattern: #{name} regexp: #{pattern_regexp} error: #{$!}"
      end
    end

    # Fill in the name field for state or pattern object.
    def fill_name(name, data, type)
      data_name = data.name ||= name
      @errors << "#{type}: #{name} has wrong name: #{data_name}" if data_name != name
    end

    # Expand all the shorthands used in the state.
    def expand_state_shorthands(name, state)
      fill_name(name, state, "State")
      state.kind ||= name
      state.transitions.each do |transition|
        transition.pattern = lookup(@syntax.patterns, "pattern", transition.pattern)
        transition.next_state = lookup(@syntax.states, "state", transition.next_state)
      end
    end

    # Convert a string name to an actual data reference.
    def lookup(mapping, type, reference)
      return reference unless String === reference
      data = mapping[reference]
      return data if data
      @errors << "Reference to a missing #{type}: #{reference}"
      return nil
    end

    # Resolve the start state reference.
    def resolve_start_state
      return lookup(@syntax.states, "state", @syntax.start_state) || {
        "name" => "missing_start_state",
        "kind" => "error",
        "transitions" => []
      }
    end

    # Scan a disk file.
    def scan_path
      File.open(@path, "r") do |file|
        scan_file(file)
      end
    end

    # Scan an opened file.
    def scan_file(file)
      @line_number = 0
      file.read.each_line do |line|
        @errors.at_line(@line_number += 1)
        scan_line(line)
      end
    end

    # Scan the next line.
    def scan_line(line)
      @state.transitions.each do |transition|
        pattern = transition.pattern
        next_state = transition.next_state
        return if pattern && next_state && classify_matching_line(line, pattern, next_state)
      end
      unclassified_line(line, @state.name)
    end

    # Handle a line that couldn't be classified.
    def unclassified_line(line, state_name)
      @lines << { "line" => line, "kind" => "error", "state" => state_name }.merge(line_location)
      @errors << "State: #{state_name} failed to classify line: #{line.chomp}"
    end

    # Handle a classified line only if it matches the pattern.
    def classify_matching_line(line, pattern, next_state)
      match = pattern.regexp.match(line)
      return false unless match
      @lines << Scanner::extracted_groups(match, pattern.groups).update({ "line" => line, "kind" => @state.kind }.merge(line_location))
      @state = next_state
      return true
    end

    # Return the location of the current line
    def line_location
      return { "location" => { "file" => @path, "line" => @line_number } }
    end

    # Extract named groups from a match.
    def self.extracted_groups(match, groups)
      extracted = {}
      groups ||= []
      groups.each_with_index do |group, index|
        extracted[group] = match[index + 1]
      end
      return extracted
    end

  end

end
