require "tempfile"

module Codnar

  # Syntax highlight using GVim.
  class GVim

    # Highlight syntax of text using GVim. This uses the GVim standard CSS
    # classes to mark keywords, identifiers, and so on. See the GVim
    # documentation for details. The commands array allows configuring the way
    # that GVim will format the output. For example:
    # * The command "+:colorscheme <name>" will override the default color
    #   scheme used.
    # * The command "+:let html_use_css=1" will just annotate each HTML tag
    #   with a CSS class, instead of embedding some specific style directly
    #   into the tag. In this case the colorscheme and background are ignored;
    #   you will need to provide your own CSS stylesheet as part of the final
    #   woven document to style the marked-up words.
    # Additional commands may be useful; GVim provides a full scripting
    # environment so there is no theoretical limit to what can be done here.
    def self.syntax_to_html(text, syntax, commands = [])
      file = write_temporary_file(text)
      run_gvim(file, syntax, commands)
      html = read_html_file(file)
      delete_temporary_files(file)
      return clean_html(html, syntax)
    end

    # Convert a sequence of classified code lines to HTML using GVim syntax
    # highlighting.
    def self.lines_to_html(lines, syntax)
      merged_line = lines[0]
      merged_line.kind = "html"
      payload = lines.map { |line| line.payload }.join("\n")
      merged_line.payload = GVim.syntax_to_html(payload, syntax).chomp
      return [ merged_line ]
    end

  protected

    # Write the text to highlight the syntax of into a temporary file.
    def self.write_temporary_file(text)
      file = Tempfile.open("codnar-")
      file.write(text)
      file.close(false)
      return file
    end

    # Run GVim to highlight the syntax of a temporary file. This uses the
    # little-known ability of GVim to emit the syntax highlighting as HTML
    # using only command-line arguments.
    def self.run_gvim(file, syntax, commands)
      path = file.path
      ENV["DISPLAY"] = "no-such-display" # Prevent GVim from flashing a GUI window.
      gvim = IO.popen("'" + [ "gvim", "-f",
             "+:let html_ignore_folding=1",
             "+:let use_xhtml=1",
             "+:let html_use_css=0",
             "+:syn on",
             "+:set syntax=#{syntax}",
             commands,
             "+run! syntax/2html.vim",
             "+:f #{path}",
             "+:wq", "+:q",
             path ].flatten.join("' '") + "' > /dev/null 2>&1", "w")
      gvim.puts # Force GVim to continue without a GUI window.
      gvim.close
    end

    # Read the HTML with the syntax highlighting written out by GVim.
    def self.read_html_file(file)
      return File.read(file.path + ".xhtml")
    end

    # Delete both the text and HTML temporary files.
    def self.delete_temporary_files(file)
      File.delete(file.path + ".xhtml")
      file.delete
    end

    # Extract the clean highlighted syntax HTML from GVim's HTML output.
    def self.clean_html(html, syntax)
      if html =~ /<pre>/
        html.sub!(/.*?<pre>/m, "<pre class='#{syntax} code syntax'>")
        html.sub!("</body>\n</html>\n", "")
      else
        html.sub!(/.*?<body/m, "<div class='#{syntax} code syntax'")
        html.sub!("</body>\n</html>\n", "</div>\n")
      end
      return html
    end

  end

end
