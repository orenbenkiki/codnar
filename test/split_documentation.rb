require "codnar"
require "test/spec"
require "with_fakefs"

module Codnar

  # Test "splitting" documentation files.
  class TestSplitDocumentation < TestWithFakeFS

    def test_split_raw
      File.open("raw.html", "w") { |file| file.write("<foo>\nbar\n</foo>\n") }
      splitter = Splitter.new(@errors, configuration("html"))
      chunks = splitter.chunks("raw.html")
      @errors.should == []
      chunks.should == [ {
        "name" => "raw.html",
        "containers" => [],
        "contained" => [],
        "locations" => [ { "file" => "raw.html", "line" => 1 } ],
        "html" => "<foo>\nbar\n</foo>"
      } ]
    end

    def test_split_markdown
      File.open("markdown.md", "w") { |file| file.write("*foo*\nbar\n") }
      splitter = Splitter.new(@errors, configuration("markdown"))
      chunks = splitter.chunks("markdown.md")
      @errors.should == []
      chunks.should == [ {
        "name" => "markdown.md",
        "containers" => [],
        "contained" => [],
        "locations" => [ { "file" => "markdown.md", "line" => 1 } ],
        "html" => "<div class='markdown markdown markup'>\n<p>\n<em>foo</em>\nbar\n</p>\n</div>"
      } ]
    end

    def test_split_rdoc
      File.open("rdoc.rdoc", "w") { |file| file.write("*foo*\nbar\n") }
      splitter = Splitter.new(@errors, configuration("rdoc"))
      chunks = splitter.chunks("rdoc.rdoc")
      @errors.should == []
      chunks.should == [ {
        "name" => "rdoc.rdoc",
        "containers" => [],
        "contained" => [],
        "locations" => [ { "file" => "rdoc.rdoc", "line" => 1 } ],
        "html" => "<div class='rdoc rdoc markup'>\n<p>\n<b>foo</b> bar\n</p>\n</div>"
      } ]
    end

    def test_split_unknown_kind
      File.open("unknown.kind", "w") { |file| file.write("foo\nbar\n") }
      splitter = Splitter.new(@errors, configuration("unknown-kind"))
      chunks = splitter.chunks("unknown.kind")
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
      chunks.should == [ {
        "name" => "unknown.kind",
        "containers" => [],
        "contained" => [],
        "locations" => [ { "file" => "unknown.kind", "line" => 1 } ],
        "html" => "<pre class='missing formatter error'>\nfoo\nbar\n</pre>"
      } ]
    end

  protected

    def configuration(kind)
      return {
        "formatters" => {
          "markdown" => "Formatter.markup_lines_to_html(lines, 'Markdown')",
          "rdoc" => "Formatter.markup_lines_to_html(lines, 'RDoc')",
        },
        "syntax" => {
          "start_state" => kind,
          "patterns" => {
            kind => { "regexp" => "^(.*)$", "groups" => [ "payload" ] },
          },
          "states" => {
            kind => {
              "transitions" => [
                { "pattern" => kind }
              ]
            }
          }
        }
      }
    end

  end

end
