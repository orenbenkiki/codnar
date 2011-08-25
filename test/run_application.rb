require "codnar"
require "olag/test"
require "test/spec"

module Codnar

  # Test running a Codnar Application.
  class TestRunApplication < Test::Unit::TestCase
  
    include Test::WithFakeFS
    include Test::WithTempfile

    def test_print_version
      Codnar::Application.with_argv(%w(-o nested/stdout -v -h dummy)) { Codnar::Application.new(true).run }.should == 0
      File.read("nested/stdout").should == "#{$0}: Version: #{Codnar::VERSION}\n"
    end

    def test_print_help
      Codnar::Application.with_argv(%w(-o stdout -h -v dummy)) { Codnar::Application.new(true).run }.should == 0
      File.read("stdout").should.include?("OPTIONS")
    end

    USER_CONFIGURATION = {
      "formatters" => {
        "doc" => "Formatter.lines_to_pre_html(lines, :class => :pre)",
      }
    }

    def test_merge_configurations
      write_fake_file("user_configuration.yaml", USER_CONFIGURATION.to_yaml)
      Codnar::Application.with_argv(%w(-o stdout -c split_pre_documentation -c user_configuration.yaml -p)) { Codnar::Application.new(true).run }.should == 0
      YAML.load_file("stdout").should == Codnar::Configuration::SPLIT_PRE_DOCUMENTATION.deep_merge(USER_CONFIGURATION)
    end

    def test_require_missing_configuration
      status = Application.with_argv(%w(-e stderr -c no-such-configuration)) { Codnar::Application.new(true).run }.should == 1
      File.read("stderr").should \
        == "#{$0}: Configuration: no-such-configuration is neither a disk file nor a known configuration\n"
    end

    def test_require_module
      FakeFS.deactivate! # The additional_module is read by Ruby and is not affected by FakeFS.
      directory = create_tempdir
      write_fake_file(directory + "/additional_module.rb", "puts 'HERE'\n")
      Application.with_argv(["-o", stdout = directory + "/stdout", "-I", directory, "-r", "additional_module" ]) { Codnar::Application.new(true).run }.should == 0
      File.read(stdout).should == "HERE\n"
    end

    def test_require_missing_module
      Application.with_argv(%w(-e stderr -I support -r no_such_module)) { Codnar::Application.new(true).run }.should == 1
      File.read("stderr").should == "#{$0}: no such file to load -- no_such_module\n"
    end

  end

end
