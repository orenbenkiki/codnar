require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test built-in split denoted comment configurations.
class TestSplitDenotedCommentsConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  def test_custom_comments
    check_any_comment("// @", "//", Codnar::Configuration::CLASSIFY_DENOTED_COMMENTS.call("// @", "//"))
  end

  def test_haddoc_comments
    check_any_comment("-- |", "--", Codnar::Configuration::CLASSIFY_HADDOCK_COMMENTS.call)
  end

protected

  # The "<<<" will be replaced by the start comment prefix,
  # and the ">>>" will be replaced by the continue comment prefix.
  ANY_COMMENT_CODE = <<-EOF.unindent
    >>> Not start comment
    <<< Start comment
    >>> Continue comment
    Not a comment
  EOF

  # The ">>>" will be replaced by the continue comment prefix.
  ANY_COMMENT_HTML = <<-EOF.unindent.chomp # ((( html
    <pre class='code'>
    >>> Not start comment
    </pre>
    <pre class='comment'>
    Start comment
    Continue comment
    </pre>
    <pre class='code'>
    Not a comment
    </pre>
  EOF
  # )))

  def check_any_comment(start_prefix, continue_prefix, configuration)
    check_split_file(ANY_COMMENT_CODE.gsub("<<<", start_prefix).gsub(">>>", continue_prefix),
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("any"),
                     Codnar::Configuration::FORMAT_PRE_COMMENTS,
                     configuration) do |path|
      [ {
        "name" => path,
        "locations" => [ { "file" => path, "line" => 1 } ],
        "containers" => [],
        "contained" => [],
        "html" => ANY_COMMENT_HTML.gsub(">>>", continue_prefix),
      } ]
    end
  end

end
