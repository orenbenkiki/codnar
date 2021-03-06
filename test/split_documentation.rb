require "codnar"
require "olag/test"
require "test/spec"

# Test "splitting" documentation files.
class TestSplitDocumentation < Test::Unit::TestCase

  include Test::WithErrors
  include Test::WithFakeFS

  def test_split_raw
    write_fake_file("raw.html", "<foo>\nbar\n</foo>\n")
    splitter = Codnar::Splitter.new(@errors, configuration("html"))
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
    write_fake_file("markdown.md", "*foo*\nbar\n")
    splitter = Codnar::Splitter.new(@errors, configuration("markdown"))
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
    write_fake_file("rdoc.rdoc", "*foo*\nbar\n")
    splitter = Codnar::Splitter.new(@errors, configuration("rdoc"))
    chunks = splitter.chunks("rdoc.rdoc")
    @errors.should == []
    chunks.should == [ {
      "name" => "rdoc.rdoc",
      "containers" => [],
      "contained" => [],
      "locations" => [ { "file" => "rdoc.rdoc", "line" => 1 } ],
      "html" => "<div class='rdoc rdoc markup'>\n<p>\n<strong>foo</strong> bar\n</p>\n</div>"
    } ]
  end

  def test_split_unknown_kind
    write_fake_file("unknown.kind", "foo\nbar\n")
    splitter = Codnar::Splitter.new(@errors, configuration("unknown-kind"))
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
        "markdown" => "Formatter.markup_lines_to_html(lines, Markdown, 'markdown')",
        "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
        "rdoc" => "Formatter.markup_lines_to_html(lines, Codnar::RDoc, 'rdoc')",
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
