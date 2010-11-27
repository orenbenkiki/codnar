require "fakefs/safe"

module Codnar

  # Seup tests that use the fake file system.
  module WithFakeFS

    def setup
      @errors = Codnar::Errors.new
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

  end

end
