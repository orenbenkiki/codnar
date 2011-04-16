require "codnar"
require "test/spec"

module Codnar

  # Test accessing data files packages with the gem.
  class TestAccessDataFiles < Test::Unit::TestCase

    def test_access_data_file
      File.exist?(DataFiles.expand_path("codnar/reader.rb")).should == true
    end

    def test_access_missing_file
      DataFiles.expand_path("no-such-file").should == "no-such-file"
    end

  end

end
