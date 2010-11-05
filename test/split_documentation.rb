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
      splitter = Splitter.new(@errors, configuration("markdown",  { "markdown" => "Codnar::Markdown.fragment_to_html(fragment)" }))
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
        "html" => ""
      } ]
      @errors.should == [ "#{$0}: Don't know how to process fragment kind: unknown-kind in file: unknown.kind at line: 1" ]
    end

  protected

    def configuration(kind, process = {})
      return {
        "process" => process,
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
