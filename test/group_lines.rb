require "codnar"
require "test/spec"

module Codnar

  # Test grouping lines by kind.
  class TestGroupLines < Test::Unit::TestCase

    def test_group_empty_lines
      Grouper.lines_to_groups([]).should == []
    end

    def test_group_one_line
      Grouper.lines_to_groups([ { "kind" => "code" } ]).should == [ [ { "kind" => "code" } ] ]
    end

    def test_group_lines
      Grouper.lines_to_groups([
        { "kind" => "code", "line" => "0\n" },
        { "kind" => "code", "line" => "1\n" },
        { "kind" => "comment", "line" => "2\n" },
        { "kind" => "code", "line" => "3\n" },
      ]).should == [ [
        { "kind" => "code", "line" => "0\n" },
        { "kind" => "code", "line" => "1\n" },
      ], [
        { "kind" => "comment", "line" => "2\n" },
      ], [
        { "kind" => "code", "line" => "3\n" },
      ] ]
    end

  end

end
