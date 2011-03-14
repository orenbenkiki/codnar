module Codnar

  # Scan a file into classified lines.
  class Scanner

    # Construct a scanner based on a syntax in the following structure:
    #
    #   patterns:
    #     <name>:
    #       name: <name>
    #       kind: <kind>
    #       regexp: <regexp>
    #       groups:
    #       - <name>
    #   states:
    #     <name>:
    #       name: <name>
    #       transitions:
    #       - pattern: <pattern>
    #         kind: <kind>
    #         next_state: <state>
    #   start_state: <state>
    #
    # To allow for cleaner YAML files to specify the syntax, the following
    # shorthands are supported:
    #
    # - A pattern or state reference can be presented by the string name of the
    #   pattern or state.
    # - The name field of a state or pattern can be ommitted. If specified, it
    #   must be identical to the key in the states or patterns mapping.
    # - The kind field of a pattern can be ommitted; by default it is assumed
    #   to be identical to the pattern name.
    # - A pattern regexp can be presented by a plain string.
    # - The pattern groups field can be ommitted or contain null if it is
    #   equal to [ "indentation", "payload" ].
    # - The kind field of a transition can be ommitted; by default it is
    #   assumed to be identical to the pattern kind.
    # - The next state of a transition can be ommitted; by default it is
    #   assumed to be identical to the containing state.
    # - The start state can be ommitted; by default it is assumed to be named
    #   "start".
    #
    # When the Scanner is constructed, a deep clone of the syntax object is
    # created and modified to expand all the above shorthands. Any problems
    # detected during this process are pushed into the errors.
    def initialize(errors, syntax)
      @errors = errors
      @syntax = syntax.deep_clone
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
    # By convention, each classified line has a "payload" group that contains
    # the "main" content of the line (chunk name for begin/end/nested chunk
    # lines, clean comment text for comment lines, etc.). In addition, most
    # classified lines have an "indentation" group that contains the leading
    # white space (which is not included in the payload).
    #
    # If at some state, a file line does not match any pattern, the scanner
    # will push a message into the errors. In addition it will classify the
    # line as follows:
    #
    #   - kind: error
    #     state: <name>
    #     line: <text>
    #     indentation: <leading white space>
    #     payload: <line text following the indentation>
    def lines(path)
      @path = path
      @lines = []
      @state = @syntax.start_state
      @errors.in_path(path) { scan_path }
      return @lines
    end

  protected

    # {{{ Scanner pattern shorthands

    # Expand all the shorthands used in the pattern.
    def expand_pattern_shorthands(name, pattern)
      pattern.kind ||= fill_name(name, pattern, "Pattern")
      pattern.groups ||= [ "indentation", "payload" ]
      pattern.regexp = convert_to_regexp(name, pattern.regexp)
    end

    # Convert a string regexp to a real Regexp.
    def convert_to_regexp(name, regexp)
      return regexp if Regexp == regexp
      begin
        return Regexp.new(regexp)
      rescue
        @errors << "Invalid pattern: #{name} regexp: #{regexp} error: #{$!}"
      end
    end

    # Fill in the name field for state or pattern object.
    def fill_name(name, data, type)
      data_name = data.name ||= name
      @errors << "#{type}: #{name} has wrong name: #{data_name}" if data_name != name
      return data_name
    end

    # }}}

    # {{{ Scanner state shorthands

    # Expand all the shorthands used in the state.
    def expand_state_shorthands(name, state)
      fill_name(name, state, "State")
      state.transitions.each do |transition|
        pattern = transition.pattern = lookup(@syntax.patterns, "pattern", transition.pattern)
        transition.kind ||= pattern.andand.kind
        transition.next_state = lookup(@syntax.states, "state", transition.next_state || state)
      end
    end

    # Convert a string name to an actual data reference.
    def lookup(mapping, type, reference)
      return reference unless String === reference
      data = mapping[reference]
      @errors << "Reference to a missing #{type}: #{reference}" unless data
      return data
    end

    # Resolve the start state reference.
    def resolve_start_state
      return lookup(@syntax.states, "state", @syntax.start_state || "start") || {
        "name" => "missing_start_state",
        "kind" => "error",
        "transitions" => []
      }
    end

    # }}}

    # {{{ Scanner file processing

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
        scan_line(line.chomp)
      end
    end

    # Scan the next file line.
    def scan_line(line)
      @state.transitions.each do |transition|
        return if transition.pattern && transition.next_state && classify_matching_line(line, transition)
      end
      unclassified_line(line, @state.name)
    end

    # }}}

    # {{{ Scanner line processing

    # Handle a file line, only if it matches the pattern.
    def classify_matching_line(line, transition)
      match = (pattern = transition.pattern).regexp.match(line)
      return false unless match
      @lines << Scanner.extracted_groups(match, pattern.groups).update({
        "line" => line,
        "kind" => transition.kind,
        "number" => @line_number
      })
      @state = transition.next_state
      return true
    end

    # Extract named groups from a match.
    def self.extracted_groups(match, groups)
      extracted = {}
      groups.each_with_index do |group, index|
        extracted[group] = match[index + 1]
      end
      return extracted
    end

    # Handle a file line that couldn't be classified.
    def unclassified_line(line, state_name)
      @lines << {
        "line" => line,
        "indentation" => line.indentation,
        "payload" => line.unindent,
        "kind" => "error",
        "state" => state_name,
        "number" => @line_number
      }
      @errors << "State: #{state_name} failed to classify line: #{@lines.last.payload}"
    end

    # }}}

  end

end
