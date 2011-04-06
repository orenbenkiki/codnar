module Codnar

  # A module for all the "built-in" configurations. The names of these
  # configurations can be passed to the --require option of any Codnar
  # Application.
  module Configuration

    # {{{ Built-in documentation "splitting" configurations

    # "Split" a documentation file. All lines are assumed to have the same kind
    # "doc" and no indentation is collected. Unless overriden by additional
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

    # }}}

    # {{{ Built-in chunk splitting configurations

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

    # }}}

    # {{{ Built-in comment splitting configurations

    # Classify lines to two kinds, "code" and (#-style) "comment". It accepts a
    # restricted format: each comment is expected to start with exactly one "#"
    # and the following space, if any, is stripped from the payload. As a
    # convenience, "#!" is not taken to start a comment. This both protects the
    # 1st line of scripts, and also any other line you wish to avoid being
    # treated as a comment.
    #
    # This configuration is typically complemented by an additional one
    # specifying how to format the code and the (stripped!) comments; by
    # default both are just displayed as-is using an HTML pre element, which
    # isn't very useful.
    CLASSIFY_SHELL_COMMENTS = {
      "formatters" => {
        "code" => "Formatter.lines_to_pre_html(lines, :class => :code)",
        "comment" => "Formatter.lines_to_pre_html(lines, :class => :comment)",
      },
      "syntax" => {
        "patterns" => {
          "comment_as_code" => { "regexp" => "^(\\s*)(#!.*)$" },
          "comment" => { "regexp" => "^(\\s*)#\\s?(.*)$" },
          "code" => { "regexp" => "^(\\s*)(.*)$" },
        },
        "states" => {
          "start" => {
            "transitions" => [
              { "pattern" => "comment_as_code", "kind" => "code" },
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

    # }}}

    # {{{ Built-in syntax highlighting configurations

    # Format code using GVim's Ruby syntax highlighting. Assumes some previous
    # configuration already classifies the code lines.
    HIGHLIGHT_CODE_SYNTAX = lambda do |syntax|
      return Configuration.gvim_code_syntax(syntax)
    end

    # Format code using GVim's Ruby syntax highlighting, using CSS classes
    # instead of explicit font and color styles. Assumes some previous
    # configuration already classifies the code lines.
    CSS_CODE_SYNTAX = lambda do |syntax|
      return Configuration.gvim_code_syntax(syntax, "'+:let html_use_css=1'")
    end

    # Return a configuration for highlighting a specific syntax using GVim.
    def self.gvim_code_syntax(syntax, extra_commands = "")
      return {
        "formatters" => {
          "code" => "Formatter.cast_lines(lines, '#{syntax}_code')",
          "#{syntax}_code" => "GVim.lines_to_html(lines, '#{syntax}', [ #{extra_commands} ])",
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
    NESTED_CODE_SYNTAX = lambda do |syntax|
      {
        "syntax" => {
          "patterns" => {
            "start_nested_#{syntax}" => { "regexp" => "^(\\s*)(.*\\(\\(\\(\\s*#{syntax}.*)$" },
            "end_nested_#{syntax}" => { "regexp" => "^(\\s*)(.*\\)\\)\\)\\s*#{syntax}.*)$" },
          },
          "states" => {
            "start" => {
              "transitions" => [
                { "pattern" => "start_nested_#{syntax}", "kind" => "code", "next_state" => syntax },
                [],
              ],
            },
            syntax => {
              "transitions" => [
                { "pattern" => "end_nested_#{syntax}", "kind" => "code", "next_state" => "start" },
                { "pattern" => "code", "kind" => "#{syntax}_code" },
              ],
            },
          },
        },
      }
    end

    # }}}

    # {{{ Built-in weaving templates

    # Weave configuration providing a single simple "include" template.
    WEAVE_INCLUDE = { "include" => "<%= chunk.expanded_html %>\n" }

    # Weave chunks in the plainest possible way.
    WEAVE_PLAIN_CHUNK = {
      "plain_chunk" => <<-EOF.unindent, #! ((( html
        <div class="plain chunk">
        <a name="<%= chunk.name.to_id %>"/>
        <%= chunk.expanded_html %>
        </div>
      EOF
    } #! ))) html

    # Weave chunks with their name and the list of container chunks.
    WEAVE_NAMED_CHUNK_WITH_CONTAINERS = {
      "named_chunk_with_containers" => <<-EOF.unindent, #! ((( html
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
    } #! ))) html

    # }}}

  end

end
