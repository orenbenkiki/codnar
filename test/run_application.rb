require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test running a Codnar application.
  class TestRunApplication < Test::Unit::TestCase

    def setup
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_do_nothing
      run_with_argv([]) { Application.new(true).run }.should == 0
    end

    def test_print_version
      run_with_argv(%w(-v -h -o stdout)) { Application.new(true).run }.should == 0
      File.read("stdout").should == "#{$0}: Version: #{Codnar::VERSION}\n"
    end

    def test_print_help
      run_with_argv(%w(-h -o stdout)) { Application.new(true).run }.should == 0
      File.read("stdout").should == Application::HELP
    end

  protected

    def run_with_argv(argv)
      return Globals.without_changes do
        ARGV.replace(argv)
        yield
      end
    end

  end

end
