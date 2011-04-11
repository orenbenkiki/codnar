require "fakefs/safe"

module Codnar

  # Setup tests that use the FakeFS fake file system.
  module TestWithFakeFS

    # Aliasing methods needs to be deferred to when the module is included and
    # be executed in the context of the class.
    def self.included(base)
      base.class_eval do

        alias_method :fakefs_original_setup, :setup

        # Automatically create an fresh fake file system for each test.
        def setup
          fakefs_original_setup
          FakeFS.activate!
          FakeFS::FileSystem.clear
        end

        alias_method :fakefs_original_teardown, :teardown

        # Automatically clean up the fake file system at the end of each test.
        def teardown
          fakefs_original_teardown
          FakeFS.deactivate!
        end

      end

    end

  end

end
