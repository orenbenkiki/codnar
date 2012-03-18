require "codnar"
require "test/spec"

# Test expanding RDoc text.
class TestExpandRDoc < Test::Unit::TestCase

  def test_emphasis_text
    Codnar::RDoc.to_html("_text_").should == "<p>\n<em>text</em>\n</p>\n"
  end

  def test_strong_text
    Codnar::RDoc.to_html("*text*").should == "<p>\n<strong>text</strong>\n</p>\n"
  end

  def test_indented_pre
    Codnar::RDoc.to_html("base\n  indented\n    more\nback\n").should \
                      == "<p>\nbase\n</p>\n<pre>indented\n  more</pre>\n<p>\nback\n</p>\n"
  end

end
