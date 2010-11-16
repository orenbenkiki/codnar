module Codnar

  # A module for all the "built-in" configurations. The names of these
  # configurations can be passed to the --require option of any Codnar
  # Application.
  module Configuration

    # Weave configuration providing a single simple "include" template.
    INCLUDE = { "include" => "<%= chunk.expanded_html %>\n" }

    # Split files into a single HTML in a pre element.
    PRE = {
      "formatters" => { "pre" => "Formatter.lines_to_pre_html(lines)" },
      "syntax" => {
        "start_state" => "pre",
        "patterns" => { "pre" => { "regexp" => "^(.*)$", "groups" => [ "payload" ] } },
        "states" => { "pre" => { "transitions" => [ { "pattern" => "pre" } ] } },
      },
    }

  end

end
