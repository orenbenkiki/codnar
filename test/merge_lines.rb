require "codnar"
require "test/spec"

module Codnar

  # Test merging classified lines to chunks.
  class TestMergeLines < Test::Unit::TestCase

    def setup
      @errors = Errors.new
    end

    def test_merge_no_chunks
      lines = [ { "kind" => "code", "line" => "foo\n", "number" => 1 } ]
      Merger.chunks(@errors, "path", lines).should == [ {
        "name" => "path",
        "locations" => [ { "file" => "path", "line" => 0 } ],
        "lines" => lines
      } ]
      @errors.should == []
    end

    def test_valid_merge
      Merger.chunks(@errors, "path", VALID_LINES).should == VALID_CHUNKS
      @errors.should == []
    end

    VALID_LINES = [
      { "kind" => "code", "line" => "before top\n", "number" => 1 },
      { "kind" => "begin_chunk", "line" => "{{{ top chunk\n", "number" => 2, "name" => "top chunk" },
      { "kind" => "code", "line" => "before intermediate\n", "number" => 3 },
      { "kind" => "begin_chunk", "line" => "{{{ intermediate chunk\n", "number" => 4, "name" => "intermediate chunk" },
      { "kind" => "code", "line" => "before inner\n", "number" => 5 },
      { "kind" => "begin_chunk", "line" => "{{{ inner chunk\n", "number" => 6, "name" => "inner chunk" },
      { "kind" => "code", "line" => "inner line\n", "number" => 7 },
      { "kind" => "end_chunk", "line" => "}}} inner chunk\n", "number" => 8, "name" => "inner chunk" },
      { "kind" => "code", "line" => "after inner\n", "number" => 9 },
      { "kind" => "end_chunk", "line" => "}}}\n", "number" => 10, "name" => "" },
      { "kind" => "code", "line" => "after intermediate\n", "number" => 11 },
      { "kind" => "end_chunk", "line" => "}}} TOP CHUNK\n", "number" => 12, "name" => "TOP CHUNK" },
      { "kind" => "code", "line" => "after top\n", "number" => 13 }
    ]

    VALID_CHUNKS = [ {
      "name" => "path",
      "locations" => [ { "file" => "path", "line" => 0 } ],
      "lines" => [
        VALID_LINES[0],
        { "kind" => "nested_chunk", "line" => "{{{ top chunk\n", "number" => 2, "name" => "top chunk" },
        VALID_LINES[12],
      ],
    }, {
      "name" => "top chunk",
      "locations" => [ { "file" => "path", "line" => 2 } ],
      "lines" => [
        VALID_LINES[1], VALID_LINES[2],
        { "kind" => "nested_chunk", "line" => "{{{ intermediate chunk\n", "number" => 4, "name" => "intermediate chunk" },
        VALID_LINES[10], VALID_LINES[11],
      ],
    }, {
      "name" => "intermediate chunk",
      "locations" => [ { "file" => "path", "line" => 4 } ],
      "lines" => [
        VALID_LINES[3], VALID_LINES[4],
        { "kind" => "nested_chunk", "line" => "{{{ inner chunk\n", "number" => 6, "name" => "inner chunk" },
        VALID_LINES[8], VALID_LINES[9],
      ],
    }, {
      "name" => "inner chunk",
      "locations" => [ { "file" => "path", "line" => 6 } ],
      "lines" => [ VALID_LINES[5], VALID_LINES[6], VALID_LINES[7] ],
    } ]

    def test_mismatching_end_chunk_line
      lines = [
        { "kind" => "begin_chunk", "line" => "{{{ top chunk\n", "number" => 1, "name" => "top chunk" },
        { "kind" => "end_chunk", "line" => "}}} not top chunk\n", "number" => 2, "name" => "not top chunk" }
      ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: End line for chunk: not top chunk mismatches begin line for chunk: top chunk in file: path at line: 2" ]
    end

    def test_missing_begin_chunk_name
      lines = [
        { "kind" => "begin_chunk", "line" => "{{{\n", "number" => 1, "name" => "" },
        { "kind" => "end_chunk", "line" => "}}}\n", "number" => 2, "name" => "" }
      ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: Begin line for chunk with no name in file: path at line: 1" ]
    end

    def test_missing_end_chunk_line
      lines = [ { "kind" => "begin_chunk", "line" => "{{{ top chunk\n", "number" => 1, "name" => "top chunk" } ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: Missing end line for chunk: top chunk in file: path at line: 1" ]
    end

  end

end
