require "codnar"
require "test/spec"

module Codnar

  # Test grouping classified lines by their kind.
  class TestGroupLines < Test::Unit::TestCase

    def test_group_empty_lines
      Grouper.lines_to_groups([]).should == []
    end

    def test_group_one_line
      Grouper.lines_to_groups([ { "kind" => "code" } ]).should == [ [ { "kind" => "code" } ] ]
    end

    def test_group_lines
      Grouper.lines_to_groups([
        { "kind" => "code", "line" => "0" },
        { "kind" => "code", "line" => "1" },
        { "kind" => "comment", "line" => "2" },
        { "kind" => "code", "line" => "3" },
      ]).should == [ [
        { "kind" => "code", "line" => "0" },
        { "kind" => "code", "line" => "1" },
      ], [
        { "kind" => "comment", "line" => "2" },
      ], [
        { "kind" => "code", "line" => "3" },
      ] ]
    end

  end

end
