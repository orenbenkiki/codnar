require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split code formatting configurations using Sunlight.
class TestSunlightFormatCodeConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

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
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("ruby"),
                     Codnar::Configuration::FORMAT_CODE_SUNLIGHT.call("ruby")) do |path|
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
