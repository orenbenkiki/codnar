module Codnar

  # A module for all the "built-in" configurations. The names of these
  # configurations can be passed to the --require option of any Codnar
  # Application.
  module Configuration

    # Weave configuration providing a single simple "include" template.
    WEAVE_INCLUDE = { "include" => "<%= chunk.expanded_html %>\n" }

    # Weave chunks in the plainest possible way.
    WEAVE_PLAIN_CHUNK = {
      "plain_chunk" => <<-EOF.unindent,
        <div class="plain chunk">
        <a name="<%= chunk.name.to_id %>"/>
        <%= chunk.expanded_html %>
        </div>
      EOF
    }

    # Weave chunks with their name and the list of container chunks.
    WEAVE_NAMED_CHUNK_WITH_CONTAINERS = {
      "named_chunk_with_containers" => <<-EOF.unindent,
        <div class="named_with_containers chunk">
        <div class="chunk name">
        <a name="<%= chunk.name.to_id %>">
        <span><%= CGI.escapeHTML(chunk.name) %></span>
        </a>
        </div>
        <div class="chunk html">
        <%= chunk.expanded_html %>
        </div>
        % if chunk.containers != []
        <div class="chunk containers">
        <span class="chunk containers header">Contained in:</span>
        <ul class="chunk containers">
        % chunk.containers.each do |container|
        <li class="chunk container">
        <a class="chunk container" href="#<%= container.to_id %>"><%= CGI.escapeHTML(container) %></a>
        </li>
        % end
        </ul>
        </div>
        % end
        </div>
      EOF
    }

    # "Split" a documentation file. All lines are assumed to have the same kind
    # "doc" and indentation is ignored. Unless overriden by additional
    # configuration(s), the lines are assumed to contain formatted HTML, and
    # are passed as-is to the output. This is the default configuration as it
    # performs the minimal amount of processing on the input. It isn't the most
    # useful configuration.
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
        "doc" => "Formatter.markup_lines_to_html(lines, 'RDoc')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      }
    )

    # "Split" a documentation file containing pure Markdown documentation.
    SPLIT_MARKDOWN_DOCUMENTATION = SPLIT_HTML_DOCUMENTATION.deep_merge(
      "formatters" => {
        "doc" => "Formatter.markup_lines_to_html(lines, 'Markdown')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      }
    )

    # Classify lines to two kinds, "code" and (#-style) "comment". It accepts a
    # restricted format: each comment is expected to start with exactly one "#"
    # and the following space, if any, is stripped from the payload. This
    # configuration is typically complemented by an additional one specifying
    # how to format the code and the (stripped!) comments; by default both are
    # just displayed as-is using an HTML pre element, which isn't very useful.
    CLASSIFY_SHELL_COMMENTS = {
      "formatters" => {
        "code" => "Formatter.lines_to_pre_html(lines, :class => :code)",
        "comment" => "Formatter.lines_to_pre_html(lines, :class => :comment)",
      },
      "syntax" => {
        "patterns" => {
          "comment" => { "regexp" => "^(\\s*)#\\s?(.*)$" },
          "code" => { "regexp" => "^(\\s*)(.*)$" },
        },
        "states" => {
          "start" => {
            "transitions" => [
              { "pattern" => "comment" },
              { "pattern" => "code" },
            ],
          },
        },
      },
    }

    # Format comments that use the RDoc notation. Is used to complement a
    # configuration that classifies some lines as "comment". Assumes some
    # previous configuration already classified the comment lines.
    FORMAT_RDOC_COMMENTS = {
      "formatters" => {
        "comment" => "Formatter.markup_lines_to_html(lines, 'RDoc')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      },
    }

    # Format comments that use the Markdown notation. Is used to complement a
    # configuration that classifies some lines as "comment". Assumes some
    # previous configuration already classifies the comment lines.
    FORMAT_MARKDOWN_COMMENTS = {
      "formatters" => {
        "comment" => "Formatter.markup_lines_to_html(lines, 'Markdown')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      },
    }

    # Format code using GVim's Ruby syntax highlighting. Assumes some previous
    # configuration already classifies the code lines.
    HIGHLIGHT_RUBY_CODE_SYNTAX = {
      "formatters" => {
        "code" => "GVim.lines_to_html(lines, 'ruby')",
      },
    }

    # Group lines into chunks using VIM-style "{{{"/"}}}" region designations.
    # Assumes other configurations handle the actual content lines.
    CHUNK_BY_VIM_REGIONS = {
      "formatters" => {
        "begin_chunk" => "[]",
        "end_chunk" => "[]",
        "nested_chunk" => "Formatter.nested_chunk_lines_to_html(lines)",
      },
      "syntax" => {
        "patterns" => {
          "begin_chunk" => { "regexp" => "^(\\s*)\\W*\\{\\{\\{\\s*(.*?)\\s*$" },
          "end_chunk" => { "regexp" => "^(\\s*)\\W*\\}\\}\\}\\s*(.*?)\\s*$" },
        },
        "states" => {
          "start" => {
            "transitions" => [
              { "pattern" => "begin_chunk" },
              { "pattern" => "end_chunk" },
              [],
            ],
          },
        },
      },
    }

  end

end
