require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test running a Codnar Application.
  class TestRunApplication < Test::Unit::TestCase

    def setup
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_do_nothing
      run_with_argv(%w(dummy)) { Application.new(true).run }.should == 0
    end

    def test_print_version
      run_with_argv(%w(-v -h -o stdout dummy)) { Application.new(true).run }.should == 0
      File.read("stdout").should == "#{$0}: Version: #{Codnar::VERSION}\n"
    end

    def test_print_help
      run_with_argv(%w(-h -o stdout dummy)) { Application.new(true).run }.should == 0
      File.read("stdout").should.include?("OPTIONS")
    end

    def test_require_configuration_module
      # The additional_module is read by Ruby and is not captured by FakeFS.
      File.open("additional_configuration.yaml", "w") { |file| file.puts("bar: updated_bar") }
      status = run_with_argv(%w(-o stdout -I support -r additional_module -c ADDITIONAL additional_configuration.yaml -- dummy)) do
        run_print_configuration
      end
      YAML.load_file("stdout").should == { "foo" => "original_foo", "bar" => "updated_bar" }
    end

    def test_require_missing_configuration
      status = run_with_argv(%w(-e stderr -I support -r additional_module -c additional no-such-configuration -- dummy)) do
        run_print_configuration
      end
      File.read("stderr").should == "#{$0}: Configuration: no-such-configuration is neither a disk file nor a known configuration\n"
    end

  protected

    def run_with_argv(argv)
      return Globals.without_changes do
        ARGV.replace(argv)
        yield
      end
    end

    def run_print_configuration
      Application.new(true).run do |configuration|
        puts configuration.to_yaml
      end
    end

  end

end
