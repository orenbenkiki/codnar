module Codnar

  # A module for all the "built-in" configurations. The names of these
  # configurations can be passed to the --require option of any Codnar
  # Application.
  module Configuration

    # Weave configuration providing a single simple "include" template.
    INCLUDE = { "include" => "<%= chunk.expanded_html %>\n" }

  end

end
