require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test expanding RDoc text.
  class TestExpandRDoc < TestCase

    def test_emphasis_text
      RDoc.to_html("_text_").should == "<p>\n<em>text</em>\n</p>\n"
    end

    def test_strong_text
      RDoc.to_html("*text*").should == "<p>\n<b>text</b>\n</p>\n"
    end

    def test_indented_pre
      RDoc.to_html("base\n  indented\n    more\nback\n").should \
        == "<p>\nbase\n</p>\n<pre>\nindented\n  more\n</pre>\n<p>\nback\n</p>\n"
    end

  end

end
