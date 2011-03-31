require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test accessing missing keys as members.
  class TestMissingKey < TestCase

    def test_read_missing_key
      {}.missing.should == nil
    end

    def test_set_missing_key
      hash = {}
      hash.missing = "value"
      hash.missing.should == "value"
    end

  end

end
