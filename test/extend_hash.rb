require "codnar"
require "test/spec"

# Test extending the Hash class.
class TestExtendHash < Test::Unit::TestCase

  def test_read_missing_key
    {}.missing.should == nil
  end

  def test_set_missing_key
    hash = {}
    hash.missing = "value"
    hash.missing.should == "value"
  end

end
