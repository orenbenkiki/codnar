module Codnar

  module Configuration

    # Configurations for splitting source code.
    module Code

      # {{{ Source code lines classification configurations

      # Classify all lines as source code of some syntax (kind). This doesn't
      # distinguish between comment and code lines; to do that, you need to
      # combine this with comment classification configuration(s). Also, it just
      # formats the lines in an HTML +pre+ element, without any syntax
      # highlighting; to do that, you need to combine this with syntax
      # highlighting formatting configuration(s).
      CLASSIFY_SOURCE_CODE = lambda do |syntax|
        return {
          "formatters" => {
            "#{syntax}_code" => "Formatter.lines_to_pre_html(lines, :class => :code)",
          },
          "syntax" => {
            "patterns" => {
              "#{syntax}_code" => { "regexp" => "^(\\s*)(.*)$" },
            },
            "states" => {
              "start" => {
                "transitions" => [
                  { "pattern" => "#{syntax}_code" },
                ],
              },
            },
          },
        }
      end

      # }}}

      # {{{ Nested foreign syntax code islands configurations

      # Allow for comments containing "((( <syntax>" and "))) <syntax>" to
      # designate nested islands of foreign syntax inside the normal code. The
      # designator comment lines are always treated as part of the surrounding
      # code, not as part of the nested foreign syntax code. There is no further
      # classification of the nested foreign syntax code. Therefore, the nested
      # code is not examined for begin/end chunk markers. Likewise, the nested
      # code may not contain deeper nested code using a third syntax.
      CLASSIFY_NESTED_CODE = lambda do |outer_syntax, inner_syntax|
        {
          "syntax" => {
            "patterns" => {
              "start_#{inner_syntax}_in_#{outer_syntax}" =>
                { "regexp" => "^(\\s*)(.*\\(\\(\\(\\s*#{inner_syntax}.*)$" },
              "end_#{inner_syntax}_in_#{outer_syntax}" => 
                { "regexp" => "^(\\s*)(.*\\)\\)\\)\\s*#{inner_syntax}.*)$" },
              "#{inner_syntax}_in_#{outer_syntax}" =>
                { "regexp" => "^(\\s*)(.*)$" },
            },
            "states" => {
              "start" => {
                "transitions" => [
                  { "pattern" => "start_#{inner_syntax}_in_#{outer_syntax}",
                    "kind" => "#{outer_syntax}_code",
                    "next_state" => "#{inner_syntax}_in_#{outer_syntax}" },
                  [],
                ],
              },
              "#{inner_syntax}_in_#{outer_syntax}" => {
                "transitions" => [
                  { "pattern" => "end_#{inner_syntax}_in_#{outer_syntax}",
                    "kind" => "#{outer_syntax}_code",
                    "next_state" => "start" },
                  { "pattern" => "#{inner_syntax}_in_#{outer_syntax}",
                    "kind" => "#{inner_syntax}_code" },
                ],
              },
            },
          },
        }
      end

      # }}}

    end

  end

end
