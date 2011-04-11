require "codnar"
require "test/spec"

module Codnar

  # Test converting chunk names to identifiers.
  class TestIdentifyChunks < Test::Unit::TestCase

    def test_lower_case_to_id
      "a".to_id.should == "a"
    end

    def test_upper_case_to_id
      "A".to_id.should == "a"
    end

    def test_digits_to_id
      "1".to_id.should == "1"
    end

    def test_non_alnum_to_id
      "!@-$#".to_id.should == "-"
    end

    def test_complex_to_id
      "C# for .NET!".to_id.should == "c-for-net-"
    end

    def test_strip_to_id
      " a ".to_id.should == "a"
    end


  end

end
