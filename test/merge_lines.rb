require "codnar"
require "test/spec"
require "with_errors"

module Codnar

  # Test merging classified lines to chunks.
  class TestMergeLines < TestWithErrors

    def test_merge_no_chunks
      lines = [ { "kind" => "code", "line" => "foo", "number" => 1, "indentation" => "", "payload" => "foo" } ]
      chunks = Merger.chunks(@errors, "path", lines)
      @errors.should == []
      chunks.should == [ {
        "name" => "path",
        "locations" => [ { "file" => "path", "line" => 1 } ],
        "containers" => [],
        "contained" => [],
        "lines" => lines
      } ]
    end

    def test_valid_merge
      chunks = Merger.chunks(@errors, "path", VALID_LINES)
      @errors.should == []
      chunks.should == VALID_CHUNKS
    end

    VALID_LINES = [
      { "kind" => "code", "line" => "before top", "number" => 1, "indentation" => "", "payload" => "before top" },
      { "kind" => "begin_chunk", "line" => " {{{ top chunk", "number" => 2, "indentation" => " ", "payload" => "top chunk" },
      { "kind" => "code", "line" => " before intermediate", "number" => 3, "indentation" => " ", "payload" => "before intermediate" },
      { "kind" => "begin_chunk", "line" => "  {{{ intermediate chunk", "number" => 4, "indentation" => "  ", "payload" => "intermediate chunk" },
      { "kind" => "code", "line" => "  before inner", "number" => 5, "indentation" => "  ", "payload" => "before inner" },
      { "kind" => "begin_chunk", "line" => "   {{{ inner chunk", "number" => 6, "indentation" => "   ", "payload" => "inner chunk" },
      { "kind" => "code", "line" => "   inner line", "number" => 7, "indentation" => "   ", "payload" => "inner line" },
      { "kind" => "end_chunk", "line" => "   }}} inner chunk", "number" => 8, "indentation" => "   ", "payload" => "inner chunk" },
      { "kind" => "code", "line" => "  after inner", "number" => 9, "indentation" => "  ", },
      { "kind" => "end_chunk", "line" => "  }}}", "number" => 10, "indentation" => "  ", "payload" => "" },
      { "kind" => "code", "line" => " after intermediate", "number" => 11, "indentation" => " ", "payload" => "after intermediate" },
      { "kind" => "end_chunk", "line" => " }}} TOP CHUNK", "number" => 12, "indentation" => " ", "payload" => "TOP CHUNK" },
      { "kind" => "code", "line" => "after top", "number" => 13, "indentation" => "", "payload" => "after top" }
    ]

    VALID_CHUNKS = [ {
      "name" => "path",
      "locations" => [ { "file" => "path", "line" => 1 } ],
      "containers" => [],
      "contained" => [ "top chunk" ],
      "lines" => [
        VALID_LINES[0].merge("indentation" => ""),
        { "kind" => "nested_chunk", "line" => " {{{ top chunk", "number" => 2, "indentation" => " ", "payload" => "top chunk" },
        VALID_LINES[12].merge("indentation" => ""),
      ],
    }, {
      "name" => "top chunk",
      "locations" => [ { "file" => "path", "line" => 2 } ],
      "containers" => [ "path" ],
      "contained" => [ "intermediate chunk" ],
      "lines" => [
        VALID_LINES[1].merge("indentation" => ""), VALID_LINES[2].merge("indentation" => ""),
        { "kind" => "nested_chunk", "line" => "  {{{ intermediate chunk", "number" => 4, "indentation" => " ", "payload" => "intermediate chunk" },
        VALID_LINES[10].merge("indentation" => ""), VALID_LINES[11].merge("indentation" => ""),
      ],
    }, {
      "name" => "intermediate chunk",
      "locations" => [ { "file" => "path", "line" => 4 } ],
      "containers" => [ "top chunk" ],
      "contained" => [ "inner chunk" ],
      "lines" => [
        VALID_LINES[3].merge("indentation" => ""), VALID_LINES[4].merge("indentation" => ""),
        { "kind" => "nested_chunk", "line" => "   {{{ inner chunk", "number" => 6, "indentation" => " ", "payload" => "inner chunk" },
        VALID_LINES[8].merge("indentation" => ""), VALID_LINES[9].merge("indentation" => ""),
      ],
    }, {
      "name" => "inner chunk",
      "locations" => [ { "file" => "path", "line" => 6 } ],
      "containers" => [ "intermediate chunk" ],
      "contained" => [],
      "lines" => [ VALID_LINES[5].merge("indentation" => ""), VALID_LINES[6].merge("indentation" => ""), VALID_LINES[7].merge("indentation" => "") ],
    } ]

    def test_mismatching_end_chunk_line
      lines = [
        { "kind" => "begin_chunk", "line" => "{{{ top chunk", "number" => 1, "indentation" => "", "payload" => "top chunk" },
        { "kind" => "end_chunk", "line" => "}}} not top chunk", "number" => 2, "indentation" => "", "payload" => "not top chunk" }
      ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: End line for chunk: not top chunk mismatches begin line for chunk: top chunk in file: path at line: 2" ]
    end

    def test_missing_begin_chunk_name
      lines = [
        { "kind" => "begin_chunk", "line" => "{{{", "number" => 1, "indentation" => "", "payload" => "" },
        { "kind" => "end_chunk", "line" => "}}}", "number" => 2, "indentation" => "", "payload" => "" }
      ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: Begin line for chunk with no name in file: path at line: 1" ]
    end

    def test_missing_end_chunk_line
      lines = [ { "kind" => "begin_chunk", "line" => "{{{ top chunk", "number" => 1, "indentation" => "", "payload" => "top chunk" } ]
      Merger.chunks(@errors, "path", lines)
      @errors.should == [ "#{$0}: Missing end line for chunk: top chunk in file: path at line: 1" ]
    end

  end

end
