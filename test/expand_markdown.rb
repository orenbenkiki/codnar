require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test expanding Markdown text.
  class TestExpandMarkdown < TestCase

    def test_emphasis_text
      Markdown.to_html("*text*").should == "<p><em>text</em></p>\n"
    end

    def test_strong_text
      Markdown.to_html("**text**").should == "<p><strong>text</strong></p>\n"
    end

    def test_embed_chunk
      Markdown.to_html("[[Chunk|template]]").should == "<p><embed src='chunk' type='x-codnar/template'/></p>\n"
    end

    def test_embed_anchor
      Markdown.to_html("[[#Name]]").should == "<p><a id='name'/></p>\n"
    end

    def test_embed_link
      Markdown.to_html("[Label](#Name)").should == "<p><a href=\"#name\">Label</a></p>\n"
    end

  end

end
