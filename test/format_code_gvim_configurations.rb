require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split code formatting configurations using GVim.
class TestGVimFormatCodeConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  CODE_TEXT = <<-EOF.unindent
    int x;
  EOF

  GVIM_HTML = <<-EOF.unindent.chomp
    <div class='c code syntax' bgcolor=\"#ffffff\" text=\"#000000\">
    <font face=\"monospace\">
    <font color=\"#00ff00\">int</font>&nbsp;x;<br />
    </font>
    </div>
  EOF

  def test_html_code
    check_any_code(GVIM_HTML, Codnar::Configuration::FORMAT_CODE_GVIM_HTML.call("c"))
  end

  GVIM_CSS = <<-EOF.unindent.chomp
    <pre class='c code syntax'>
    <span class=\"Type\">int</span> x;
    </pre>
  EOF

  def test_css_code
    check_any_code(GVIM_CSS, Codnar::Configuration::FORMAT_CODE_GVIM_CSS.call("c"))
  end

protected

  def check_any_code(html, configuration)
    check_split_file(CODE_TEXT,
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("c"),
                     configuration) do |path|
      [ {
        "name" => path,
        "locations" => [ { "file" => path, "line" => 1 } ],
        "containers" => [],
        "contained" => [],
        "html" => html,
      } ]
    end
  end

end
