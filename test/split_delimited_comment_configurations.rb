require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split delimited comment configurations.
class TestSplitDelimitedCommentsConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  def test_custom_comments
    # Since the prefix/inner/suffix passed to the configuration are regexps,
    # we need to escape special characters such as "{" and "|".
    check_any_comment([ "@{", " |", " }@" ], Codnar::Configuration::CLASSIFY_DELIMITED_COMMENTS.call("@\\{", " \\|", " \\}@"))
  end

  def test_c_comments
    check_any_comment([ "/*", " *", " */" ], Codnar::Configuration::CLASSIFY_C_COMMENTS.call)
  end

  def test_html_comments
    check_any_comment([ "<!--", " -", "-->" ], Codnar::Configuration::CLASSIFY_HTML_COMMENTS.call)
  end

protected

  # The "<<<" will be replaced by the start comment prefix,
  # the "<>" will be replaced by the inner line comment prefix,
  # and the ">>>" will be replaced by the end comment suffix.
  ANY_COMMENT_CODE = <<-EOF.unindent
    <<< One-line comment >>>
    Code
    <<<
    <> Multi-line
    <> comment.
    >>>
  EOF

  ANY_COMMENT_HTML = <<-EOF.unindent.chomp # ((( html
    <pre class='comment'>
    One-line comment
    </pre>
    <pre class='code'>
    Code
    </pre>
    <pre class='comment'>

    Multi-line
    comment.

    </pre>
  EOF
  # )))

  def check_any_comment(patterns, configuration)
    prefix, inner, suffix = patterns
    check_split_file(ANY_COMMENT_CODE.gsub("<<<", prefix).gsub(">>>", suffix).gsub("<>", inner),
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("any"),
                     Codnar::Configuration::FORMAT_PRE_COMMENTS,
                     configuration) do |path|
      [ {
        "name" => path,
        "locations" => [ { "file" => path, "line" => 1 } ],
        "containers" => [],
        "contained" => [],
        "html" => ANY_COMMENT_HTML.gsub("/--", prefix).gsub("--/", suffix).gsub(" -", inner),
      } ]
    end
  end

end
