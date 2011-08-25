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
    write_fake_file("input", "<foo>\n")
    Codnar::Application.with_argv(%w(-o stdout input)) { Codnar::Split.new(true).run }.should == 0
    YAML.load_file("stdout").should == [ {
      "name" => "input",
      "locations" => [ { "file" => "input", "line" => 1 } ],
      "html" => "<foo>",
      "containers" => [],
      "contained" => [],
    } ]
  end

end
