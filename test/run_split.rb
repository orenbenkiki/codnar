require "codnar"
require "olag/test"
require "test/spec"

# Test running the Split Codnar Application.
class TestRunSplit < Test::Unit::TestCase

  include Test::WithFakeFS

  def test_print_help
    Codnar::Application.with_argv(%w(-o stdout -h)) { Codnar::Split.new(true).run }.should == 0
    help = File.read("stdout")
    [ "codnar-split", "OPTIONS", "DESCRIPTION" ].each { |text| help.should.include?(text) }
  end

  def test_run_split
    File.open("input", "w") { |file| file.puts("<foo>") }
    Codnar::Application.with_argv(%w(-o stdout input)) { Codnar::Split.new(true).run }.should == 0
    YAML.load_file("stdout").should == [ {
      "name" => "input",
      "locations" => [ { "file" => "input", "line" => 1 } ],
      "html" => "<foo>",
      "containers" => [],
      "contained" => [],
    } ]
  end

  def test_run_split_no_file
    Codnar::Application.with_argv(%w(-e stderr)) { Codnar::Split.new(true).run }.should == 1
    File.read("stderr").should == "#{$0}: No input file to split\n"
  end

  def test_run_split_many_file
    Codnar::Application.with_argv(%w(-e stderr one two)) { Codnar::Split.new(true).run }.should == 1
    File.read("stderr").should == "#{$0}: Too many input files to split\n"
  end

end
