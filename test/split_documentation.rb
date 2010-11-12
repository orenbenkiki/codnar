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
        "html" => "<foo>\nbar\n</foo>\n"
      } ]
      @errors.should == []
    end

    def test_split_markdown
      File.open("markdown.md", "w") { |file| file.write("*foo*\nbar\n") }
      splitter = Splitter.new(@errors, configuration("markdown"))
      splitter.chunks("markdown.md").should == [ {
        "name" => "markdown.md",
        "locations" => [ { "file" => "markdown.md", "line" => 1 } ],
        "html" => "<div class='markdown'>\n<p><em>foo</em>\nbar</p>\n</div>\n"
      } ]
      @errors.should == []
    end

    def test_split_rdoc
      File.open("rdoc.rdoc", "w") { |file| file.write("*foo*\nbar\n") }
      splitter = Splitter.new(@errors, configuration("rdoc"))
      splitter.chunks("rdoc.rdoc")#.should == [ {
        #"name" => "rdoc.rdoc",
        #"locations" => [ { "file" => "rdoc.rdoc", "line" => 1 } ],
        #"html" => "<div class='rdoc'>\n<p>\n<b>foo</b> bar\n</p>\n</div>\n"
      #} ]
      @errors.should == []
    end

    def test_split_unknown_kind
      File.open("unknown.kind", "w") { |file| file.write("foo\nbar\n") }
      splitter = Splitter.new(@errors, configuration("unknown-kind"))
      splitter.chunks("unknown.kind").should == [ {
        "name" => "unknown.kind",
        "locations" => [ { "file" => "unknown.kind", "line" => 1 } ],
        "html" => "<pre class='missing_formatter'>\nfoo\nbar\n</pre>\n"
      } ]
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
    end

  protected

    def configuration(kind)
      return {
        "formatters" => {
          "markdown" => "Formatter.markup_to_html(lines, 'Markdown')",
          "rdoc" => "Formatter.markup_to_html(lines, 'RDoc')",
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
