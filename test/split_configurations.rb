require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test the built-in split configurations.
  class TestSplitConfigurations < Test::Unit::TestCase

    def test_split_html_documentation
      check_split_file(Configuration::SPLIT_HTML_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RUBY_FILE.chomp
        } ]
      end
    end

    def test_split_pre_documentation
      check_split_file(Configuration::SPLIT_PRE_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => "<pre class='doc'>\n" + RUBY_FILE + "</pre>"
        } ]
      end
    end

    RDOC_HTML = <<-EOF.unindent.chomp
      <div class='rdoc doc markup'>
      <p>
      # This is <b>special</b>.
      </p>
      <pre>
        # {{{ assignment
        local = $global
        # }}}
      </pre>
      </div>
    EOF

    def test_split_rdoc_documentation
      check_split_file(Configuration::SPLIT_RDOC_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RDOC_HTML,
        } ]
      end
    end

    MARKDOWN_HTML = <<-EOF.unindent.chomp
      <div class='markdown doc markup'>
      <h1>This is <em>special</em>.</h1>

      <p>  # {{{ assignment
        local = $global
        # }}}</p>
      </div>
    EOF

    def test_split_markdown_documentation
      check_split_file(Configuration::SPLIT_MARKDOWN_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => MARKDOWN_HTML,
        } ]
      end
    end

    SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp
      <pre class='comment'>
      This is *special*.
      {{{ assignment
      </pre>
      <pre class='code'>
      local = $global
      </pre>
      <pre class='comment'>
      }}}
      </pre>
    EOF

    def test_classify_shell_comments
      check_split_file(Configuration::CLASSIFY_SHELL_COMMENTS) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => SHELL_COMMENTS_HTML,
        } ]
      end
    end

    RDOC_SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp
      <div class='rdoc comment markup'>
      <p>
      This is <b>special</b>. {{{ assignment
      </p>
      </div>
      <pre class='code'>
      local = $global
      </pre>
      <div class='rdoc comment markup'>
      <p>
      }}}
      </p>
      </div>
    EOF

    def test_classify_shell_comments_and_format_rdoc_comments
      check_split_file(Configuration::CLASSIFY_SHELL_COMMENTS,
                       Configuration::FORMAT_RDOC_COMMENTS) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RDOC_SHELL_COMMENTS_HTML,
        } ]
      end
    end

    MARKDOWN_SHELL_COMMENTS_HTML = <<-EOF.unindent.chomp
      <div class='markdown comment markup'>
      <p>This is <em>special</em>.
      {{{ assignment</p>
      </div>
      <pre class='code'>
      local = $global
      </pre>
      <div class='markdown comment markup'>
      <p>}}}</p>
      </div>
    EOF

    def test_classify_shell_comments_and_format_markdown_comments
      check_split_file(Configuration::CLASSIFY_SHELL_COMMENTS,
                       Configuration::FORMAT_MARKDOWN_COMMENTS) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => MARKDOWN_SHELL_COMMENTS_HTML,
        } ]
      end
    end

    HIGHLIGHT_RUBY_HTML = <<-EOF.unindent.chomp
      <pre class='comment'>
      This is *special*.
      {{{ assignment
      </pre>
      <pre class='ruby code syntax'>
      local = <span class="Identifier">$global</span>
      </pre>
      <pre class='comment'>
      }}}
      </pre>
    EOF

    def test_classify_shell_comments_and_highlight_ruby_code_syntax
      check_split_file(Configuration::CLASSIFY_SHELL_COMMENTS,
                       Configuration::HIGHLIGHT_RUBY_CODE_SYNTAX) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => HIGHLIGHT_RUBY_HTML,
        } ]
      end
    end

    FULL_RUBY_PROCESSING_TOP_CHUNK_HTML = <<-EOF.unindent.chomp
      <div class='rdoc comment markup'>
      <p>
      This is <b>special</b>.
      </p>
      </div>
      <pre class='nested chunk'>
        <a class='nested chunk' href='assignment'>assignment</a>
      </pre>
    EOF

    FULL_RUBY_PROCESSING_NESTED_CHUNK_HTML = <<-EOF.unindent.chomp
      <pre class='ruby code syntax'>
      local = <span class="Identifier">$global</span>
      </pre>
    EOF

    def test_classify_shell_comments_and_highlight_ruby_code_syntax_and_format_rdoc_comments_and_chunk_by_vim_regions
      check_split_file(Configuration::CLASSIFY_SHELL_COMMENTS,
                       Configuration::HIGHLIGHT_RUBY_CODE_SYNTAX,
                       Configuration::FORMAT_RDOC_COMMENTS,
                       Configuration::CHUNK_BY_VIM_REGIONS) do |path|
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

  protected

    def check_split_file(*configurations, &block)
      configuration = configurations.inject({}) { |merged_configuration, next_configuration| merged_configuration.deep_merge(next_configuration) }
      splitter = Splitter.new(errors = Errors.new, configuration)
      chunks = splitter.chunks(path = write_ruby_file)
      errors.should == []
      chunks.should == yield(path)
    end

    def write_ruby_file
      file = Tempfile.open("ruby.rb")
      file.write(RUBY_FILE)
      file.close(false)
      return file.path
    end

    RUBY_FILE = <<-EOF.unindent
      # This is *special*.
        # {{{ assignment
        local = $global
        # }}}
    EOF

  end

end
