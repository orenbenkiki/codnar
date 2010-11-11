require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test formatting chunks to HTML.
  class TestFormatChunks < Test::Unit::TestCase

    def setup
      Formatter.send(:public, *Formatter.protected_instance_methods)
    end

    def test_group_empty_lines
      Formatter.grouped_lines([]).should == []
    end

    def test_group_one_line
      Formatter.grouped_lines([ { "kind" => "code" } ]).should == [ [ { "kind" => "code" } ] ]
    end

    def test_group_lines
      Formatter.grouped_lines([
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
