module Codnar

  module Configuration

    # Configurations for "splitting" documentation files.
    module Documentation

      # "Split" a documentation file. All lines are assumed to have the same kind
      # +doc+ and no indentation is collected. Unless overriden by additional
      # configuration(s), the lines are assumed to contain formatted HTML, and
      # are passed as-is to the output.
      #
      # This is the default configuration as it performs the minimal amount of
      # processing on the input. It isn't the most useful configuration.
      SPLIT_HTML_DOCUMENTATION = {
        "formatters" => {
          "doc" => "Formatter.cast_lines(lines, 'html')",
        },
        "syntax" => {
          "patterns" => {
            "doc" => { "regexp" => "^(.*)$", "groups" => [ "payload" ] },
          },
          "states" => {
            "start" => { "transitions" => [ { "pattern" => "doc" } ] },
          },
        },
      }

      # "Split" a documentation file containing arbitrary text, which is
      # preserved by escaping it and wrapping it in an HTML pre element.
      SPLIT_PRE_DOCUMENTATION = SPLIT_HTML_DOCUMENTATION.deep_merge(
        "formatters" => {
          "doc" => "Formatter.lines_to_pre_html(lines, :class => :doc)",
        }
      )

      # "Split" a documentation file containing pure RDoc documentation.
      SPLIT_RDOC_DOCUMENTATION = SPLIT_HTML_DOCUMENTATION.deep_merge(
        "formatters" => {
          "doc" => "Formatter.markup_lines_to_html(lines, Codnar::RDoc, 'rdoc')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        }
      )

      # "Split" a documentation file containing pure Markdown documentation.
      SPLIT_MARKDOWN_DOCUMENTATION = SPLIT_HTML_DOCUMENTATION.deep_merge(
        "formatters" => {
          "doc" => "Formatter.markup_lines_to_html(lines, Codnar::Markdown, 'markdown')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        }
      )

      # "Split" a documentation file containing a GraphViz diagram.
      SPLIT_GRAPHVIZ_DOCUMENTATION = SPLIT_HTML_DOCUMENTATION.deep_merge(
        "formatters" => {
          "doc" => "Formatter.markup_lines_to_html(lines, Codnar::GraphViz, 'graphviz')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        }
      )

    end

  end

end
