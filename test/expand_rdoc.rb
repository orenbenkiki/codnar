require "codnar"
require "test/spec"

module Codnar

  # Test expanding RDoc text.
  class TestExpandRDoc < Test::Unit::TestCase

    def test_emphasis_text
      RDoc.rdoc_to_html("_text_").should == "<p>\n<em>text</em>\n</p>"
    end

    def test_strong_text
      RDoc.rdoc_to_html("*text*").should == "<p>\n<b>text</b>\n</p>"
    end

  end

end
