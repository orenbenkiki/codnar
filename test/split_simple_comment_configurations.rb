require "codnar"
require "test/spec"
require "test_with_errors"
require "test_with_configurations"
require "test_with_tempfile"

module Codnar

  # Test built-in split simple comment configurations.
  class TestSplitSimpleCommentsConfigurations < Test::Unit::TestCase
  
    include TestWithErrors
    include TestWithConfigurations
    include TestWithTempfile

    def test_custom_comments
      check_any_comment("!", Configuration::CLASSIFY_SIMPLE_COMMENTS.call("!"))
    end

    def test_shell_comments
      check_any_comment("#", Configuration::CLASSIFY_SHELL_COMMENTS.call)
    end

    def test_cpp_comments
      check_any_comment("//", Configuration::CLASSIFY_CPP_COMMENTS.call)
    end

  protected

    # The "?" will be replaced by the simple comment prefix.
    ANY_COMMENT_CODE = <<-EOF.unindent
      ?
      ? Comment
      Code
      ?! Not comment
    EOF

    def check_any_comment(prefix, configuration)
      check_split_file(ANY_COMMENT_CODE.gsub("?", prefix),
                       Configuration::CLASSIFY_SOURCE_CODE.call("any"),
                       Configuration::FORMAT_PRE_COMMENTS,
                       configuration) do |path|
        [ {
          "name" => path,
          "locations" => [ { "file" => path, "line" => 1 } ],
          "containers" => [],
          "contained" => [],
          "html" => "<pre class='comment'>\n\nComment\n</pre>\n<pre class='code'>\nCode\n#{prefix}! Not comment\n</pre>"
        } ]
      end
    end

  end

end
