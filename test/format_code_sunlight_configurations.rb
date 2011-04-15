require "codnar"
require "test/spec"
require "test_with_configurations"
require "test_with_errors"
require "test_with_tempfile"

module Codnar

  # Test built-in split code formatting configurations using Sunlight.
  class TestSunlightFormatCodeConfigurations < Test::Unit::TestCase
  
    include TestWithErrors
    include TestWithConfigurations
    include TestWithTempfile

    CODE_TEXT = <<-EOF.unindent
      local = $global;
    EOF

    SUNLIGHT_HTML = <<-EOF.unindent.chomp
      <pre class='sunlight-highlight-ruby'>
      local = $global;
      </pre>
    EOF

    def test_sunlight_code
      check_split_file(CODE_TEXT,
                       Configuration::CLASSIFY_SOURCE_CODE.call("ruby"),
                       Configuration::FORMAT_CODE_SUNLIGHT.call("ruby")) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => SUNLIGHT_HTML,
        } ]
      end
    end

  end

end
