require "codnar"
require "test/spec"
require "test_with_errors"
require "test_with_configurations"
require "test_with_tempfile"

module Codnar

  # Test built-in split code formatting configurations.
  class TestSplitChunkConfigurations < Test::Unit::TestCase
  
    include TestWithErrors
    include TestWithConfigurations
    include TestWithTempfile

    CODE_TEXT = <<-EOF.unindent.gsub("#!", "#")
      int x;
      #! {{{ chunk
      int y;
      #! }}}
    EOF

    CODE_HTML = <<-EOF.unindent.chomp
      <pre class='code'>
      int x;
      </pre>
      <pre class='nested chunk'>
      <a class='nested chunk' href='#chunk'>chunk</a>
      </pre>
    EOF

    CHUNK_HTML = <<-EOF.unindent.chomp
      <pre class='code'>
      int y;
      </pre>
    EOF

    def test_gvim_chunks
      check_split_file(CODE_TEXT,
                       Configuration::CLASSIFY_SOURCE_CODE.call("c"),
                       Configuration::CHUNK_BY_VIM_REGIONS) do |path|
        [ {
          "name"=> path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [ "chunk" ],
          "html"=> CODE_HTML,
        }, {
          "name" => "chunk",
          "locations" => [ { "file" => path, "line" => 2 } ],
          "containers" => [ path ],
          "contained" => [],
          "html" => CHUNK_HTML,
        } ]
      end
    end

  end

end
