module Codnar

  module Configuration

    # Configurations for splitting source code with comments.
    module Comments

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
        return Comments.simple_comments(prefix)
      end

      # Classify simple shell ("#") comment lines.
      CLASSIFY_SHELL_COMMENTS = lambda do
        return Comments.simple_comments("#")
      end

      # Classify simple C++ ("//") comment lines.
      CLASSIFY_CPP_COMMENTS = lambda do
        return Comments.simple_comments("//")
      end

      # Configuration for classifying lines to comments and code based on a
      # simple prefix (e.g. "#" for shell style comments or "//" for C++ style
      # comments).
      def self.simple_comments(prefix)
        return {
          "syntax" => {
            "patterns" => {
              "comment_#{prefix}" => { "regexp" => '^(\s*)' + prefix + '(?!!)\\s?(.*)$' },
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

      # {{{ Denoted comment classification configurations

      # Classify denoted comment lines. Denoted comments are similar to simple
      # comments, except that the 1st simple comment line must start with a
      # specific prefix (e.g., in haddock, comment lines start with '--' but
      # haddoc comments start with '-- |', '-- ^', etc.). The comment continues
      # in additional simple comment lines.
      #
      # This configuration is typically complemented by an additional one
      # specifying how to format the (stripped!) comments; by default they are
      # just displayed as-is using an HTML +pre+ element, which isn't very
      # useful.
      CLASSIFY_DENOTED_COMMENTS = lambda do |start_prefix, continue_prefix|
        return Comments.denoted_comments(start_prefix, continue_prefix)
      end

      # Classify denoted haddock ("--") comment lines. Note that non-haddock
      # comment lines are not captured; they would treated as code and handled
      # by syntax highlighting, if any.
      CLASSIFY_HADDOCK_COMMENTS = lambda do
        return Comments.denoted_comments("-- [|^$]", "--")
      end

      # Configuration for classifying lines to comments and code based on a start
      # comment prefix and continuation comment prefix (e.g., "-- |" and "--" for
      # haddock).
      def self.denoted_comments(start_prefix, continue_prefix)
        # Ruby coverage somehow barfs if we inline this. Go figure.
        start_transition = {
          "pattern" => "comment_start_#{start_prefix}",
          "next_state" => "comment_continue_#{continue_prefix}",
          "kind" => "comment"
        }
        return {
          "syntax" => {
            "patterns" => {
              "comment_start_#{start_prefix}" => { "regexp" => '^(\s*)' + start_prefix+ '\s?(.*)$' },
              "comment_continue_#{continue_prefix}" => { "regexp" => '^(\s*)' + continue_prefix + '\s?(.*)$' },
            },
            "states" => {
              "start" => {
                "transitions" => [ start_transition, [] ],
              },
              "comment_continue_#{continue_prefix}" => {
                "transitions" => [ {
                    "pattern" => "comment_continue_#{continue_prefix}",
                    "kind" => "comment" },
                  { "next_state" => "start" }
                ],
              },
            },
          },
        }
      end

      # }}}

      # {{{ Delimited comment classification configurations

      # Classify delimited comment lines. It accepts a restricted format: each
      # comment is expected to start with some exact prefix (e.g. "/*" for C
      # style comments or "<!--" for HTML style comments). The following space,
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
      CLASSIFY_DELIMITED_COMMENTS = lambda do |prefix, inner, suffix|
        return Comments.delimited_comments(prefix, inner, suffix)
      end

      # Classify delimited C ("/*", " *", " */") style comments.
      CLASSIFY_C_COMMENTS = lambda do
        # Since the prefix/inner/suffix passed to the configuration are regexps,
        # we need to escape special characters such as "*".
        return Comments.delimited_comments('/\*', ' \*', ' \*/')
      end

      # Classify delimited HTML ("<!--", " -", "-->") style comments.
      CLASSIFY_HTML_COMMENTS = lambda do
        return Comments.delimited_comments("<!--", " -", "-->")
      end

      # Classify delimited Elixir style comments. These start with `@doc """`,
      # end with `"""`, and have no prefix for the inner lines.
      CLASSIFY_ELIXIR_COMMENTS = lambda do
        return Comments.delimited_comments('@[a-z]*doc\s+"""', nil, '"""')
      end

      # Configuration for classifying lines to comments and code based on a
      # delimited start prefix, inner line prefix and final suffix (e.g., "/*", "
      # *", " */" for C-style comments or "<!--", " -", "-->" for HTML style
      # comments).
      def self.delimited_comments(prefix, inner, suffix)
        return {
          "syntax" => {
            "patterns" => {
              "comment_prefix_#{prefix}" => { "regexp" => '^(\s*)' + prefix + '(?!!)\s?(.*)$' },
              "comment_inner_#{inner}" => { "regexp" => inner.nil? ? "^()(.*)$" : '^(\s*)' + inner + '\s?(.*)$' },
              "comment_suffix_#{suffix}" => { "regexp" => '^(\s*)' + suffix + '\s*$' },
              "comment_line_#{prefix}_#{suffix}" => { "regexp" => '^(\s*)' + prefix + '(?!!)\s?(.*?)\s*' + suffix + '\s*$' },
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
          "comment" => "Formatter.markup_lines_to_html(lines, Codnar::RDoc, 'rdoc')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        },
      }

      # Format comments that use the Markdown notation. Is used to complement a
      # configuration that classifies some lines as +comment+.
      FORMAT_MARKDOWN_COMMENTS = {
        "formatters" => {
          "comment" => "Formatter.markup_lines_to_html(lines, Markdown, 'markdown')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        },
      }

      # Format comments that use the Haddock notation. Is used to complement a
      # configuration that classifies some lines as +comment+.
      FORMAT_HADDOCK_COMMENTS = {
        "formatters" => {
          "comment" => "Formatter.markup_lines_to_html(lines, Haddock, 'haddock')",
          "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        },
      }

      # }}}

    end

  end

end
