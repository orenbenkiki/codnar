require "codnar"
require "test/spec"
require "test_with_errors"
#! require "test_with_fakefs" - current version (0.3.1) does not work with tempfile.
require "test_with_configurations"
require "test_with_tempfile"

module Codnar

  # Test the built-in split documentation configurations.
  class TestSplitDocumentationConfigurations < Test::Unit::TestCase
  
    include TestWithErrors
    #! include TestWithFakeFS - until FakeFS fixes the tempfile issue.
    include TestWithConfigurations
    include TestWithTempfile

    HTML_FILE = <<-EOF.unindent #! ((( html
      <p>This is an
      HTML file.</p>
    EOF
    # ))) html

    def test_split_html_documentation
      check_split_file(HTML_FILE, Configuration::SPLIT_HTML_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => HTML_FILE.chomp
        } ]
      end
    end

    PRE_FILE = <<-EOF.unindent
      This is a preformatted
      raw text file.
    EOF

    def test_split_pre_documentation
      check_split_file(PRE_FILE, Configuration::SPLIT_PRE_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => "<pre class='doc'>\n" + PRE_FILE + "</pre>"
        } ]
      end
    end

    MARKUP_FILE = <<-EOF.unindent
      This is a
      *marked-up* file.
    EOF

    RDOC_HTML = <<-EOF.unindent.chomp #! ((( html
      <div class='rdoc doc markup'>
      <p>
      This is a <b>marked-up</b> file.
      </p>
      </div>
    EOF
    # ))) html

    def test_split_rdoc_documentation
      check_split_file(MARKUP_FILE, Configuration::SPLIT_RDOC_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => RDOC_HTML,
        } ]
      end
    end

    MARKDOWN_HTML = <<-EOF.unindent.chomp #! ((( html
      <div class='markdown doc markup'>
      <p>
      This is a
      <em>marked-up</em> file.
      </p>
      </div>
    EOF
    #! ))) html

    def test_split_markdown_documentation
      check_split_file(MARKUP_FILE, Configuration::SPLIT_MARKDOWN_DOCUMENTATION) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => MARKDOWN_HTML,
        } ]
      end
    end

  end

end
