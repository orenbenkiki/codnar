require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split code formatting configurations.
class TestFormatCodeConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  def test_gvim_html_code
    check_any_code(<<-EOF.unindent.chomp, Codnar::Configuration::FORMAT_CODE_GVIM_HTML.call("c"))
      <div class='c code syntax' bgcolor=\"#ffffff\" text=\"#000000\">
      <font face=\"monospace\">
      <font color=\"#00ff00\">int</font>&nbsp;x;<br />
      </font>
      </div>
    EOF
  end

  def test_gvim_css_code
    check_any_code(<<-EOF.unindent.chomp, Codnar::Configuration::FORMAT_CODE_GVIM_CSS.call("c"))
      <pre class='c code syntax'>
      <span class=\"Type\">int</span> x;
      </pre>
    EOF
  end

  def test_coderay_html_code
    check_any_code(<<-EOF.unindent.chomp, Codnar::Configuration::FORMAT_CODE_CODERAY_HTML.call("c"))
      <div class="CodeRay">
        <div class="code"><pre><span style="color:#0a5;font-weight:bold">int</span> x;</pre></div>
      </div>
    EOF
  end

  def test_coderay_css_code
    check_any_code(<<-EOF.unindent.chomp, Codnar::Configuration::FORMAT_CODE_CODERAY_CSS.call("c"))
      <div class="CodeRay">
        <div class="code"><pre><span class="predefined-type">int</span> x;</pre></div>
      </div>
    EOF
  end

  def test_sunlight_code
    check_any_code(<<-EOF.unindent.chomp, Codnar::Configuration::FORMAT_CODE_SUNLIGHT.call("c"))
      <pre class='sunlight-highlight-c'>
      int x;
      </pre>
    EOF
  end

protected

  def check_any_code(html, configuration)
    check_split_file("int x;\n",
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
