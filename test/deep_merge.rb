require "codnar"
require "test/spec"
require "test_case"

module Codnar

  # Test deep-merging complex structures.
  class TestDeepMerge < TestCase

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
