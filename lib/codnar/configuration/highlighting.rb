module Codnar

  module Configuration

    # Configurations for highlighting source code lines.
    module Highlighting

      # {{{ GVim syntax highlighting formatting configurations

      # Format code using GVim's syntax highlighting, using explicit HTML
      # constructs. Assumes some previous configuration already classified the
      # code lines.
      FORMAT_CODE_GVIM_HTML = lambda do |syntax|
        return Highlighting.klass_code_format('GVim', syntax, "[]")
      end

      # Format code using GVim's syntax highlighting, using CSS classes instead
      # of explicit font and color styles. Assumes some previous configuration
      # already classified the code lines.
      FORMAT_CODE_GVIM_CSS = lambda do |syntax|
        return Highlighting.klass_code_format('GVim', syntax, "[ '+:let html_use_css=1' ]")
      end

      # Return a configuration for highlighting a specific syntax using GVim.
      def self.klass_code_format(klass, syntax, options)
        return {
          "formatters" => {
            "#{syntax}_code" => "#{klass}.lines_to_html(lines, '#{syntax}', #{options})",
          },
        }
      end

      # }}}

      # {{{ CodeRay syntax highlighting formatting configurations

      # Format code using CodeRay's syntax highlighting, using explicit HTML
      # constructs. Assumes some previous configuration already classified the
      # code lines.
      FORMAT_CODE_CODERAY_HTML = lambda do |syntax|
        return Highlighting.klass_code_format('CodeRay', syntax, "{}")
      end

      # Format code using CodeRay's syntax highlighting, using CSS classes
      # instead of explicit font and color styles. Assumes some previous
      # configuration already classified the code lines.
      FORMAT_CODE_CODERAY_CSS = lambda do |syntax|
        return Highlighting.klass_code_format('CodeRay', syntax, "{ :css => :class }")
      end

      # }}}

      # {{{ Sunlight syntax highlighting formatting configurations

      # Format code using Sunlight's syntax highlighting. This assumes the HTML
      # will include and invoke Sunlight's Javascript file which does the
      # highlighting on the fly inside the DOM, instead of pre-computing it when
      # splitting the file.
      FORMAT_CODE_SUNLIGHT = lambda do |syntax|
        return Highlighting.sunlight_code_format(syntax)
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

end
