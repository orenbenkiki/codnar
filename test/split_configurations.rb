require "codnar"
require "test/spec"
require "with_errors"

module Codnar

  # Test the built-in split configurations.
  class TestSplitConfigurations < TestWithErrors

    def test_split_html_documentation
      check_split_file([ Configuration::SPLIT_HTML_DOCUMENTATION ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => SIMPLE_FILE.chomp
        } ]
      end
    end

    def test_split_pre_documentation
      check_split_file([ Configuration::SPLIT_PRE_DOCUMENTATION ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => "<pre class='doc'>\n" + SIMPLE_FILE + "</pre>"
        } ]
      end
    end

    RDOC_HTML = <<-EOF.unindent.gsub("#!", "#").chomp #! ((( html
      <div class='rdoc doc markup'>
      <p>
      #! This is <b>special</b>.
      </p>
      <pre>
      #! {{{ assignment
      local = $global
        indented
      #! }}}
      </pre>
      </div>
    EOF
    # ))) html

    def test_split_rdoc_documentation
      check_split_file([ Configuration::SPLIT_RDOC_DOCUMENTATION ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RDOC_HTML,
        } ]
      end
    end

    MARKDOWN_HTML = <<-EOF.unindent.gsub("#!", "#").chomp #! ((( html
      <div class='markdown doc markup'>
      <h1>This is <em>special</em>.</h1>
      <p>
        #! {{{ assignment
        local = $global
      </p>
      <pre>
      <code>indented
      </code>
      </pre>
      <p>
        #! }}}
      </p>
      </div>
    EOF
    #! ))) html

    def test_split_markdown_documentation
      check_split_file([ Configuration::SPLIT_MARKDOWN_DOCUMENTATION ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => MARKDOWN_HTML,
        } ]
      end
    end

    SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp #! ((( html
      <pre class='comment'>
      This is *special*.
        {{{ assignment
      </pre>
      <pre class='code'>
        local = $global
          indented
      </pre>
      <pre class='comment'>
        }}}
      </pre>
    EOF
    #! ))) html

    def test_classify_shell_comments
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => SHELL_COMMENTS_HTML,
        } ]
      end
    end

    INDENTATION_TABLE_PREFIX = <<-EOF.unindent.chomp #! ((( html
      <table class='layout'>
      <tr>
      <td class='indentation'>
      <pre>INDENTATION</pre>
      </td>
      <td class='html'>
    EOF
    #! ))) html

    INDENTATION_TABLE_SUFFIX = <<-EOF.unindent.chomp #! ((( html
      </td>
      </tr>
      </table>
    EOF
    #! ))) html

    RDOC_SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp #! ((( html
      #{INDENTATION_TABLE_PREFIX.sub("INDENTATION", "")}
      <div class='rdoc comment markup'>
      <p>
      This is <b>special</b>. {{{ assignment
      </p>
      </div>
      #{INDENTATION_TABLE_SUFFIX}
      <pre class='code'>
        local = $global
          indented
      </pre>
      #{INDENTATION_TABLE_PREFIX.sub("INDENTATION", "  ")}
      <div class='rdoc comment markup'>
      <p>
      }}}
      </p>
      </div>
      #{INDENTATION_TABLE_SUFFIX}
    EOF
    #! ))) html

    def test_classify_shell_comments_and_format_rdoc_comments
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS,
                         Configuration::FORMAT_RDOC_COMMENTS ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RDOC_SHELL_COMMENTS_HTML,
        } ]
      end
    end

    MARKDOWN_SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp #! ((( html
      #{INDENTATION_TABLE_PREFIX.sub("INDENTATION", "")}
      <div class='markdown comment markup'>
      <p>
      This is <em>special</em>.
      {{{ assignment
      </p>
      </div>
      #{INDENTATION_TABLE_SUFFIX}
      <pre class='code'>
        local = $global
          indented
      </pre>
      #{INDENTATION_TABLE_PREFIX.sub("INDENTATION", "  ")}
      <div class='markdown comment markup'>
      <p>
      }}}
      </p>
      </div>
      #{INDENTATION_TABLE_SUFFIX}
    EOF
    #! ))) html

    def test_classify_shell_comments_and_format_markdown_comments
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS,
                         Configuration::FORMAT_MARKDOWN_COMMENTS ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => MARKDOWN_SHELL_COMMENTS_HTML,
        } ]
      end
    end

    HIGHLIGHT_RUBY_HTML = <<-EOF.unindent.chomp #! ((( html
      <pre class='comment'>
      This is *special*.
        {{{ assignment
      </pre>
      <div class='ruby code syntax' bgcolor="#ffffff" text="#000000">
      <font face="monospace">
      &nbsp;&nbsp;local =&nbsp;<font color="#00ffff">$global</font><br />
      &nbsp;&nbsp;&nbsp;&nbsp;indented<br />
      </font>
      </div>
      <pre class='comment'>
        }}}
      </pre>
    EOF
    #! ))) html

    def test_classify_shell_comments_and_highlight_ruby_code_syntax
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS,
                         Configuration::HIGHLIGHT_CODE_SYNTAX.call('ruby') ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => HIGHLIGHT_RUBY_HTML,
        } ]
      end
    end

    FULL_RUBY_PROCESSING_TOP_CHUNK_HTML = <<-EOF.unindent.chomp #! ((( html
      #{INDENTATION_TABLE_PREFIX.sub("INDENTATION", "")}
      <div class='rdoc comment markup'>
      <p>
      This is <b>special</b>.
      </p>
      </div>
      #{INDENTATION_TABLE_SUFFIX}
      <pre class='nested chunk'>
        <a class='nested chunk' href='#assignment'>assignment</a>
      </pre>
    EOF
    #! ))) html

    FULL_RUBY_PROCESSING_NESTED_CHUNK_HTML = <<-EOF.unindent.chomp #! ((( html
     <pre class='ruby code syntax'>
     local = <span class="Identifier">$global</span>
       indented
     </pre>
    EOF
    #! ))) html

    def test_classify_shell_comments_and_css_ruby_code_syntax_and_format_rdoc_comments_and_chunk_by_vim_regions
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS,
                         Configuration::CSS_CODE_SYNTAX.call('ruby'),
                         Configuration::FORMAT_RDOC_COMMENTS,
                         Configuration::CHUNK_BY_VIM_REGIONS ]) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [ "assignment" ],
          "html" => FULL_RUBY_PROCESSING_TOP_CHUNK_HTML,
        }, {
          "name" => "assignment",
          "locations" => [ { "file" => path, "line" => 2 } ],
          "containers" => [ path ],
          "contained" => [],
          "html" => FULL_RUBY_PROCESSING_NESTED_CHUNK_HTML,
        } ]
      end
    end

    NESTED_SYNTAX_HTML = <<-EOF.unindent.chomp #! ((( html
      <pre class='ruby code syntax'>
      <span class="PreProc">#! This is ruby code</span>
      local = <span class="Identifier">$global</span>
      html = &lt;&lt;<span class="Special">EOH</span> <span class="Comment">#! ((( html</span>
      </pre>
      <pre class='html code syntax'>
      <span class="Identifier">&lt;</span><span class="Statement">p</span><span class="Identifier">&gt;</span>
      This is HTML
      <span class="Identifier">&lt;/</span><span class="Statement">p</span><span class="Identifier">&gt;</span>
      EOH
      </pre>
      <pre class='ruby code syntax'>
      <span class="PreProc">#! ))) html</span>
      </pre>
    EOF
    #! ))) html

    def test_classify_nested_syntax
      check_split_file([ Configuration::CLASSIFY_SHELL_COMMENTS,
                         Configuration::CSS_CODE_SYNTAX.call('html'),
                         Configuration::CSS_CODE_SYNTAX.call('ruby'), #! Last one is the default.
                         Configuration::NESTED_CODE_SYNTAX.call('html') ], NESTED_FILE) do |path|

        [ {
          "name" => path,
           "locations" => [ { "file" => path, "line" => 1 } ],
          "html" => NESTED_SYNTAX_HTML,
          "containers" => [],
          "contained" => []
        } ]
      end
    end

  protected

    def check_split_file(configurations, file_text = SIMPLE_FILE, &block)
      configuration = configurations.inject({}) { |merged_configuration, next_configuration| merged_configuration.deep_merge(next_configuration) }
      splitter = Splitter.new(@errors, configuration)
      chunks = splitter.chunks(path = write_tempfile("ruby.rb", file_text))
      @errors.should == []
      chunks.should == yield(path)
    end

    SIMPLE_FILE = <<-EOF.unindent.gsub("#!", "#")
      #! This is *special*.
        #! {{{ assignment
        local = $global
          indented
        #! }}}
    EOF

    NESTED_FILE = <<-EOF.unindent
      #! This is ruby code
      local = $global
      html = <<EOH #! ((( html
      <p>
      This is HTML
      </p>
      EOH
      #! ))) html
    EOF

  end

end
