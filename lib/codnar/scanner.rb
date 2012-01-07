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
    # - The pattern groups field can be ommitted or contain +nil+ if it is
    #   equal to [ "indentation", "payload" ].
    # - The kind field of a transition can be ommitted; by default it is
    #   assumed to be identical to the pattern kind. If it ends up +nil+, this
    #   indicates that there's no kind assigned by the pattern, and the current
    #   line should be classified again by the next state.
    # - The next state of a transition can be ommitted; by default it is
    #   assumed to be identical to the containing state.
    # - The start state can be ommitted; by default it is assumed to be named
    #   +start+.
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
      @errors.in_file_lines(path) { |line| scan_line(line.chomp) }
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

    # A pattern that matches any line and extracts no data; is meant to be used
    # for catch-all transitions that transfer the scanning to a different
    # state. It is used if no explicit pattern is specified in a transition
    # (that is, you can think of this as the +nil+ pattern).
    CATCH_ALL_PATTERN = {
      "kind" => nil,
      "groups" => [],
      "regexp" => //
    }

    # Expand all the shorthands used in the state.
    def expand_state_shorthands(name, state)
      fill_name(name, state, "State")
      state.transitions.each do |transition|
        pattern = transition.pattern = lookup(@syntax.patterns, "pattern", transition.pattern || CATCH_ALL_PATTERN)
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

    # Scan the next file line.
    def scan_line(line)
      until state_classified_line(line)
        # Do nothing
      end
    end

    # Scan the current line using the current state transitions. Return true if
    # the line was classified, of false if we need to try and classify it again
    # using the updated (next) state.
    def state_classified_line(line)
      @state.transitions.each do |transition|
        match = transition.pattern.andand.regexp.andand.match(line) if transition.next_state
        return classify_matching_line(line, transition, match) if match
      end
      classify_error_line(line, @state.name)
      return true
    end

    # }}}

    # {{{ Scanner line processing

    # Handle a file line, only if it matches the pattern.
    def classify_matching_line(line, transition, match)
      @state = transition.next_state
      kind = transition.kind
      return false unless kind # A +nil+ kind indicates the next state will classify the line.
      @lines << Scanner.extracted_groups(match, transition.pattern.groups || []).update({
        "line" => line,
        "kind" => kind,
        "number" => @errors.line_number
      })
      return true
    end

    # Extract named groups from a match. As a special case, indentation is
    # deleted if there is no payload.
    def self.extracted_groups(match, groups)
      extracted = {}
      groups.each_with_index do |group, index|
        extracted[group] = match[index + 1]
      end
      extracted.delete("indentation") if match[0] == ""
      return extracted
    end

    # Handle a file line that couldn't be classified.
    def classify_error_line(line, state_name)
      @lines << {
        "line" => line,
        "indentation" => line.indentation,
        "payload" => line.unindent,
        "kind" => "error",
        "state" => state_name,
        "number" => @errors.line_number
      }
      @errors << "State: #{state_name} failed to classify line: #{@lines.last.payload}"
    end

    # }}}

  end

end
