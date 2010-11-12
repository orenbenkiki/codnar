require "codnar"
require "test/spec"

module Codnar

  # Test expanding Markdown text.
  class TestExpandMarkdown < Test::Unit::TestCase

    def test_emphasis_text
      Markdown.md_to_html("*text*").should == "<p><em>text</em></p>\n"
    end

    def test_strong_text
      Markdown.md_to_html("**text**").should == "<p><strong>text</strong></p>\n"
    end

  end

end
