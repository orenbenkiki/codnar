require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split comment formatting configurations.
class TestFormatCommentsConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  COMMENT_TEXT = <<-EOF.unindent.gsub("#!", "#")
    #! Comment *text*.
  EOF

  PRE_HTML = <<-EOF.unindent.chomp
    <pre class='comment'>
    Comment *text*.
    </pre>
  EOF

  def test_pre_comments
    check_any_format(PRE_HTML, Codnar::Configuration::FORMAT_PRE_COMMENTS)
  end

  RDOC_HTML = <<-EOF.unindent.chomp
    <table class='layout'>
    <tr>
    <td class='indentation'>
    <pre></pre>
    </td>
    <td class='html'>
    <div class='rdoc comment markup'>
    <p>
    Comment <strong>text</strong>.
    </p>
    </div>
    </td>
    </tr>
    </table>
  EOF

  def test_rdoc_comments
    check_any_format(RDOC_HTML, Codnar::Configuration::FORMAT_RDOC_COMMENTS)
  end

  MARKDOWN_HTML = <<-EOF.unindent.chomp
    <table class='layout'>
    <tr>
    <td class='indentation'>
    <pre></pre>
    </td>
    <td class='html'>
    <div class='markdown comment markup'>
    <p>
    Comment <em>text</em>.
    </p>
    </div>
    </td>
    </tr>
    </table>
  EOF

  def test_markdown_comments
    check_any_format(MARKDOWN_HTML, Codnar::Configuration::FORMAT_MARKDOWN_COMMENTS)
  end

protected

  def check_any_format(html, configuration)
    check_split_file(COMMENT_TEXT,
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("any"),
                     Codnar::Configuration::CLASSIFY_SHELL_COMMENTS.call,
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
