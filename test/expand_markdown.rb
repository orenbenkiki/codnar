require "codnar"
require "test/spec"

# Test expanding Markdown text.
class TestExpandMarkdown < Test::Unit::TestCase

  def test_emphasis_text
    Markdown.to_html("*text*").should == "<p>\n<em>text</em>\n</p>\n"
  end

  def test_strong_text
    Markdown.to_html("**text**").should == "<p>\n<strong>text</strong>\n</p>\n"
  end

  def test_embed_chunk
    Markdown.to_html("[[Chunk|template]]").should == "<p>\n<embed src='chunk' type='x-codnar/template'/>\n</p>\n"
  end

  def test_embed_anchor
    Markdown.to_html("[[#Name]]").should == "<p>\n<a id='name'/>\n</p>\n"
  end

  def test_embed_link
    Markdown.to_html("[Label](#Name)").should == "<p>\n<a href=\"#name\">Label</a>\n</p>\n"
  end

end
