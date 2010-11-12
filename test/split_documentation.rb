require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test "splitting" documentation files.
  class TestSplitDocumentation < Test::Unit::TestCase

    def setup
      @errors = Errors.new
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_split_raw
      File.open("raw.html", "w") { |file| file.write("<foo>\nbar\n</foo>\n") }
      splitter = Splitter.new(@errors, configuration("html"))
      splitter.chunks("raw.html").should == [ {
        "name" => "raw.html",
        "locations" => [ { "file" => "raw.html", "line" => 1 } ],
        "html" => "<foo>\nbar\n</foo>"
      } ]
      @errors.should == []
    end

    def test_split_markdown
      File.open("markdown.md", "w") { |file| file.write("*foo*\nbar\n") }
      splitter = Splitter.new(@errors, configuration("markdown"))
      splitter.chunks("markdown.md").should == [ {
        "name" => "markdown.md",
        "locations" => [ { "file" => "markdown.md", "line" => 1 } ],
        "html" => "<p><em>foo</em>\nbar</p>"
      } ]
      @errors.should == []
    end

    def test_split_unknown_kind
      File.open("unknown.kind", "w") { |file| file.write("foo\nbar\n") }
      splitter = Splitter.new(@errors, configuration("unknown-kind"))
      splitter.chunks("unknown.kind").should == [ {
        "name" => "unknown.kind",
        "locations" => [ { "file" => "unknown.kind", "line" => 1 } ],
        "html" => "<pre class='missing_formatter'>foo\nbar</pre>"
      } ]
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
    end

  protected

    def configuration(kind)
      return {
        "formatters" => { "markdown" => "Markdown.lines_to_html(lines)" },
        "syntax" => {
          "start_state" => kind,
          "patterns" => {
            kind => { "regexp" => "^(.*)$", "groups" => [ kind ] },
          },
          "states" => {
            kind => {
              "transitions" => [
                { "pattern" => kind, "next_state" => kind }
              ]
            }
          }
        }
      }
    end

  end

end
