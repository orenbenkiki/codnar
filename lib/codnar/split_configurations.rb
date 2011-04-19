module Codnar

  # A module for all the "built-in" configurations. The names of these
  # configurations can be passed to the --require option of any Codnar
  # Application.
  module Configuration

    # {{{ Documentation "splitting" configurations

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

    # {{{ Simple comment classification configurations

    # Classify simple comment lines. It accepts a restricted format: each
    # comment is expected to start with some exact prefix (e.g. "#" for shell
    # style comments or "//" for C++ style comments). The following space, if
    # any, is stripped from the payload. As a convenience, comment that starts
    # with "!" is not taken to start a comment. This both protects the 1st line
    # of shell scripts ("#!"), and also any other line you wish to avoid being
    # treated as a comment.
    #
    # This configuration is typically complemented by an additional one
    # specifying how to format the (stripped!) comments; by default they are
    # just displayed as-is using an HTML +pre+ element, which isn't very
    # useful.
    CLASSIFY_SIMPLE_COMMENTS = lambda do |prefix|
      return Configuration.simple_comments(prefix)
    end

    # Classify simple shell ("#") comment lines.
    CLASSIFY_SHELL_COMMENTS = lambda do
      return Configuration.simple_comments("#")
    end

    # Classify simple C++ ("//") comment lines.
    CLASSIFY_CPP_COMMENTS = lambda do
      return Configuration.simple_comments("//")
    end

    # Configuration for classifying lines to comments and code based on a
    # simple prefix (e.g. "#" for shell style comments or "//" for C++ style
    # comments).
    def self.simple_comments(prefix)
      return {
        "syntax" => {
          "patterns" => {
            "comment_#{prefix}" => { "regexp" => "^(\\s*)#{prefix}(?!!)\\s?(.*)$" },
          },
          "states" => {
            "start" => {
              "transitions" => [
                { "pattern" => "comment_#{prefix}", "kind" => "comment" },
                []
              ],
            },
          },
        },
      }
    end

    # }}}

    # {{{ Complex comment classification configurations

    # Classify complex comment lines. It accepts a restricted format: each
    # comment is expected to start with some exact prefix (e.g. "/*" for C
    # style comments or "<!--" for HTML++ style comments). The following space,
    # if any, is stripped from the payload. Following lines are also considered
    # comments; a leading inner line prefix (e.g., " *" for C style comments or
    # " -" for HTML style comments) with an optional following space are
    # stripped from the payload. Finally, a line containing some exact suffix
    # (e.g. "*/" for C style comments, or "-->" for HTML style comments) ends
    # the comment. A one line comment format is also supported containing the
    # prefix, the payload, and the suffix. As a convenience, comment that
    # starts with "!" is not taken to start a comment. This allows protecting
    # comment block you wish to avoid being classified as a comment.
    #
    # This configuration is typically complemented by an additional one
    # specifying how to format the (stripped!) comments; by default they are
    # just displayed as-is using an HTML +pre+ element, which isn't very
    # useful.
    CLASSIFY_COMPLEX_COMMENTS = lambda do |prefix, inner, suffix|
      return Configuration.complex_comments(prefix, inner, suffix)
    end

    # Classify complex C ("/*", " *", " */") style comments.
    CLASSIFY_C_COMMENTS = lambda do
      # Since the prefix/inner/suffix passed to the configuration are regexps,
      # we need to escape special characters such as "*".
      return Configuration.complex_comments("/\\*", " \\*", " \\*/")
    end

    # Classify complex HTML ("<!--", " -", "-->") style comments.
    CLASSIFY_HTML_COMMENTS = lambda do
      return Configuration.complex_comments("<!--", " -", "-->")
    end

    # Configuration for classifying lines to comments and code based on a
    # complex start prefix, inner line prefix and final suffix (e.g., "/*", "
    # *", " */" for C-style comments or "<!--", " -", "-->" for HTML style
    # comments).
    def self.complex_comments(prefix, inner, suffix)
      return {
        "syntax" => {
          "patterns" => {
            "comment_prefix_#{prefix}" => { "regexp" => "^(\\s*)#{prefix}(?!!)\\s?(.*)$" },
            "comment_inner_#{inner}" => { "regexp" => "^(\\s*)#{inner}\\s?(.*)$" },
            "comment_suffix_#{suffix}" => { "regexp" => "^(\\s*)#{suffix}\\s*$" },
            "comment_line_#{prefix}_#{suffix}" => { "regexp" => "^(\\s*)#{prefix}(?!!)\s?(.*?)\s*#{suffix}\\s*$" },
          },
          "states" => {
            "start" => {
              "transitions" => [
                { "pattern" => "comment_line_#{prefix}_#{suffix}",
                  "kind" => "comment" },
                { "pattern" => "comment_prefix_#{prefix}",
                  "kind" => "comment",
                  "next_state" => "comment_#{prefix}" },
                [],
              ],
            },
            "comment_#{prefix}" => {
              "transitions" => [
                { "pattern" => "comment_suffix_#{suffix}",
                  "kind" => "comment",
                  "next_state" => "start" },
                { "pattern" => "comment_inner_#{inner}",
                  "kind" => "comment" },
              ],
            },
          },
        },
      }
    end

    # }}}

    # {{{ Comment formatting configurations

    # Format comments as HTML pre elements. Is used to complement a
    # configuration that classifies some lines as +comment+.
    FORMAT_PRE_COMMENTS = {
      "formatters" => {
        "comment" => "Formatter.lines_to_pre_html(lines, :class => :comment)",
      },
    }

    # Format comments that use the RDoc notation. Is used to complement a
    # configuration that classifies some lines as +comment+.
    FORMAT_RDOC_COMMENTS = {
      "formatters" => {
        "comment" => "Formatter.markup_lines_to_html(lines, 'RDoc')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      },
    }

    # Format comments that use the Markdown notation. Is used to complement a
    # configuration that classifies some lines as +comment+.
    FORMAT_MARKDOWN_COMMENTS = {
      "formatters" => {
        "comment" => "Formatter.markup_lines_to_html(lines, 'Markdown')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
      },
    }

    # }}}
    
    # {{{ GVim syntax highlighting formatting configurations

    # Format code using GVim's Ruby syntax highlighting, using explicit HTML
    # constructs. Assumes some previous configuration already classified the
    # code lines.
    FORMAT_CODE_GVIM_HTML = lambda do |syntax|
      return Configuration.gvim_code_format(syntax)
    end

    # Format code using GVim's Ruby syntax highlighting, using CSS classes
    # instead of explicit font and color styles. Assumes some previous
    # configuration already classified the code lines.
    FORMAT_CODE_GVIM_CSS = lambda do |syntax|
      return Configuration.gvim_code_format(syntax, "'+:let html_use_css=1'")
    end

    # Return a configuration for highlighting a specific syntax using GVim.
    def self.gvim_code_format(syntax, extra_commands = "")
      return {
        "formatters" => {
          "#{syntax}_code" => "GVim.lines_to_html(lines, '#{syntax}', [ #{extra_commands} ])",
        },
      }
    end

    # }}}

    # {{{ Sunlight syntax highlighting formatting configurations

    # Format code using Sunlight's syntax highlighting. This assumes the HTML
    # will include and invoke Sunlight's Javascript file which does the
    # highlighting on the fly inside the DOM, instead of pre-computing it when
    # splitting the file.
    FORMAT_CODE_SUNLIGHT = lambda do |syntax|
      return Configuration.sunlight_code_format(syntax)
    end

    # Return a configuration for highlighting a specific syntax using Sunlight.
    def self.sunlight_code_format(syntax)
      return {
        "formatters" => {
          "#{syntax}_code" => "Sunlight.lines_to_html(lines, '#{syntax}')",
        },
      }
    end

    # }}}

    # {{{ Chunk splitting configurations

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

  end

end
