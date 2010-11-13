require "codnar"
require "test/spec"

module Codnar

  # Test deep merging of hashes.
  class TestDeepMerge < Test::Unit::TestCase

    def test_deep_merge
      { "a" => "av", "b" => { "ba" => "bav", "bb" => "bbv" }, "c" => "cv",
      }.deep_merge("a" => "AV", "b" => { "bb" => "BBV", "bc" => "BCV" }
      ).should == { "a" => "AV", "b" => { "ba" => "bav", "bb" => "BBV", "bc" => "BCV" }, "c" => "cv" }
    end

  end

end
