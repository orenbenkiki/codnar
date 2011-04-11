require "codnar"
require "test/spec"
require "test_with_fakefs"

module Codnar

  # Test running the Split Codnar Application.
  class TestRunSplit < Test::Unit::TestCase
  
    include TestWithFakeFS

    def test_print_help
      Application.with_argv(%w(-h -o stdout)) { Split.new(true).run }.should == 0
      help = File.read("stdout")
      [ "codnar-split", "OPTIONS", "DESCRIPTION" ].each { |text| help.should.include?(text) }
    end

    def test_run_split
      File.open("input", "w") { |file| file.puts("<foo>") }
      Application.with_argv(%w(-o stdout input)) { Split.new(true).run }.should == 0
      YAML.load_file("stdout").should == [ {
        "name" => "input",
        "locations" => [ { "file" => "input", "line" => 1 } ],
        "html" => "<foo>",
        "containers" => [],
        "contained" => [],
      } ]
    end

    def test_run_split_no_file
      Application.with_argv(%w(-e stderr)) { Split.new(true).run }.should == 1
      File.read("stderr").should == "#{$0}: No input file to split\n"
    end

    def test_run_split_many_file
      Application.with_argv(%w(-e stderr one two)) { Split.new(true).run }.should == 1
      File.read("stderr").should == "#{$0}: Too many input files to split\n"
    end

  end

end
