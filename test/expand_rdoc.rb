require "codnar"
require "test/spec"

module Codnar

  # Test expanding RDoc text.
  class TestExpandRDoc < Test::Unit::TestCase

    def test_emphasis_text
      RDoc.to_html("_text_").should == "<p>\n<em>text</em>\n</p>\n"
    end

    def test_strong_text
      RDoc.to_html("*text*").should == "<p>\n<b>text</b>\n</p>\n"
    end

  end

end
