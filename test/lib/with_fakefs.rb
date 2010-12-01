require "fakefs/safe"
require "with_errors"

module Codnar

  # Seup tests that use the FakeFS fake file system.
  class TestWithFakeFS < TestWithErrors

    def setup
      super
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      super
      FakeFS.deactivate!
    end

  end

end
