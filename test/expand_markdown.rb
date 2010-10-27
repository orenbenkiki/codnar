require "codnar"
require "test/spec"

# Test expanding Markdown text.
class TestExpandMarkdown < Test::Unit::TestCase

  def test_emphasis_text
    "*text*".md_to_html.should == "<p><em>text</em></p>\n"
  end

  def test_strong_text
    "**text**".md_to_html.should == "<p><strong>text</strong></p>\n"
  end

end
