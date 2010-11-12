require "tempfile"

module Codnar

  # Syntax highlight using GVim.
  class GVim

    # Highlight syntax of text using GVim. This uses the GVim standard CSS
    # classes to mark keywords, identifiers, and so on. See the GVim
    # documentation for details.
    def self.syntax_to_html(text, syntax)
      file = write_temporary_file(text)
      run_gvim(file, syntax)
      html = read_html_file(file)
      delete_temporary_files(file)
      return clean_html(html)
    end

    # Convert a sequence of code lines to HTML using GVim syntax highlighting.
    def self.lines_to_html(lines, syntax)
      merged_line = lines[0]
      merged_line.kind = "html"
      merged_line.html = GVim.syntax_to_html(lines.map { |line| line[syntax] }.join("\n"), syntax).chomp
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
    def self.run_gvim(file, syntax)
      path = file.path
      ENV["DISPLAY"] = "no-such-display" # Prevent GVim from flashing a GUI window.
      gvim = IO.popen("'" + [ "gvim", "-f",
             "+:let html_ignore_folding=1",
             "+:let html_use_css=1",
             "+:syn on",
             "+:set syntax=#{syntax}",
             "+run! syntax/2html.vim",
             "+:f #{path}",
             "+:wq", "+:q",
             path ].join("' '") + "' > /dev/null 2>&1", "w")
      gvim.puts # Force GVim to continue without a GUI window.
      gvim.close
    end

    # Read the HTML with the syntax highlighting written out by GVim.
    def self.read_html_file(file)
      return File.read(file.path + ".html")
    end

    # Delete both the text and HTML temporary files.
    def self.delete_temporary_files(file)
      File.delete(file.path + ".html")
      file.delete
    end

    # Extract the clean highlighted syntax HTML from GVim's HTML output.
    def self.clean_html(html)
      html.sub!(/.*?<pre>/m, "<pre class='highlighted_syntax'>")
      html.sub!("</body>\n</html>\n", "")
      return html
    end

  end

end
