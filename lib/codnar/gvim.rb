module Codnar

  # Syntax highlight using GVim.
  class GVim

    # Convert a sequence of classified code lines to HTML using GVim syntax
    # highlighting. The commands array allows configuring the way that GVim
    # will format the output (see the +cached_syntax_to_html+ method for
    # details).
    def self.lines_to_html(lines, syntax, commands = [])
      return Formatter.merge_lines(lines, "html") do |payload|
        GVim.cached_syntax_to_html(payload + "\n", syntax, commands).chomp
      end
    end

    # The cache used for speeding up recomputing the same syntax highlighting
    # HTML.
    @cache = Cache.new(".gvim-cache") do |data|
      GVim.uncached_syntax_to_html(data.text, data.syntax, data.commands)
    end

    # Force recomputation of the syntax highlighting HTML, even if a cached
    # version exists.
    def self.force_recompute=(force_recompute)
      @cache.force_recompute = force_recompute
    end

    # Highlight syntax of text using GVim. This uses the GVim standard CSS
    # classes to mark keywords, identifiers, and so on. See the GVim
    # documentation for details. The commands array allows configuring the way
    # that GVim will format the output. For example:
    #
    # * The command <tt>"+:colorscheme <name>"</tt> will override the default
    #   color scheme used.
    # * The command <tt>"+:let html_use_css=1"</tt> will just annotate each
    #   HTML tag with a CSS class, instead of embedding some specific style
    #   directly into the tag. In this case the colorscheme and background are
    #   ignored; you will need to provide your own CSS stylesheet as part of
    #   the final woven document to style the marked-up words.
    #
    # Additional commands may be useful; GVim provides a full scripting
    # environment so there is no theoretical limit to what can be done here.
    #
    # Since GVim is as slow as molasses to start up, we cache the results of
    # highlighting the syntax of each code fragment in a directory called
    # <tt>.gvim-cache</tt>, which can appear at the current working directory
    # or in any of its parents.
    def self.cached_syntax_to_html(text, syntax, commands = [])
      data = { "text" => text, "syntax" => syntax, "commands" => commands }
      return @cache[data]
    end

    # Highlight syntax of text using GVim, without caching. This is *slow*
    # (measured in seconds), due to GVim's start-up tim. See the
    # +cached_syntax_to_html+ method for a faster variant and functionality
    # details.
    def self.uncached_syntax_to_html(text, syntax, commands = [])
      file = write_temporary_file(text)
      run_gvim(file, syntax, commands)
      html = read_html_file(file)
      delete_temporary_files(file)
      return clean_html(html, syntax)
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
      ENV["DISPLAY"] = "none" # Otherwise the X11 server *does* affect the result.
      command = [
        "gvim",
        "-f", "-X",
        "-u", "none",
        "-U", "none",
        "+:let html_ignore_folding=1",
        "+:let use_xhtml=1",
        "+:let html_use_css=0",
        "+:syn on",
        "+:set syntax=#{syntax}",
        commands,
        "+run! syntax/2html.vim",
        "+:f #{path}",
        "+:wq", "+:q",
        path
      ]
      system("echo '\n' | '#{command.flatten.join("' '")}' > /dev/null 2>&1")
    end

    # Read the HTML with the syntax highlighting written out by GVim.
    def self.read_html_file(file)
      return File.read(html_file_path(file))
    end

    # Delete both the text and HTML temporary files.
    def self.delete_temporary_files(file)
      File.delete(html_file_path(file))
      file.delete
    end

    # Find the path of the generate HTML file. You'd think it would be
    # predictable, but it ends up either ".html" or ".xhtml" depending on the
    # system.
    def self.html_file_path(file)
      return Dir.glob(file.path + ".*html")[0]
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
