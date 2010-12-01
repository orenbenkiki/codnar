require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test extending the Hash class.
  class TestExtendHash < TestCase

    def test_read_missing_key
      {}.missing.should == nil
    end

    def test_set_missing_key
      hash = {}
      hash.missing = "value"
      hash.missing.should == "value"
    end

    def test_deep_merge
      default = {
        "only_default" => "default_value",
        "overriden" => "default_value",
        "overriden_array" => [ "default_value" ],
        "merged_array" => [ "default_value" ],
      }
      override = {
        "only_override" => "overriden_value",
        "overriden" => "overriden_value",
        "overriden_array" => [ "overriden_value" ],
        "merged_array" => [ "overriden_value", [] ],
      }
      default.deep_merge(override).should == {
        "only_default" => "default_value",
        "only_override" => "overriden_value",
        "overriden" => "overriden_value",
        "overriden_array" => [ "overriden_value" ],
        "merged_array" => [ "overriden_value", "default_value" ],
      }
    end

  end

end
