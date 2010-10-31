require "codnar"
require "test/spec"

# Test unindenting a multi-line text.
class TestUnindentText < Test::Unit::TestCase

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
