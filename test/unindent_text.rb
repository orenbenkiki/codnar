require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test unindenting a multi-line text.
  class TestUnindentText < TestCase

    def test_automatic_unindent
      "  a\n    b\n".unindent.should == "a\n  b\n"
    end

    def test_invalid_unindent
      "    a\n  b\n".unindent.should == "a\n  b\n"
    end

    def test_explicit_unindent
      "  a\n    b\n".unindent(" ").should == " a\n   b\n"
    end

  end

end
