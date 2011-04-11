require "codnar"
require "test/spec"
require "test_with_errors"
require "test_with_configurations"
require "test_with_tempfile"

module Codnar

  # Test built-in split complex comment configurations.
  class TestSplitComplexCommentsConfigurations < Test::Unit::TestCase
  
    include TestWithErrors
    include TestWithConfigurations
    include TestWithTempfile

    def test_custom_comments
      # Since the prefix/inner/suffix passed to the configuration are regexps,
      # we need to escape special characters such as "{" and "|".
      check_any_comment([ "@{", " |", " }@" ], Configuration::CLASSIFY_COMPLEX_COMMENTS.call("@\\{", " \\|", " \\}@"))
    end

    def test_c_comments
      check_any_comment([ "/*", " *", " */" ], Configuration::CLASSIFY_C_COMMENTS.call)
    end

    def test_html_comments
      check_any_comment([ "<!--", " -", "-->" ], Configuration::CLASSIFY_HTML_COMMENTS.call)
    end

  protected

    # The "<<<" will be replaced by the complex comment prefix,
    # the "<>" will be replaced by the inner line comment prefix,
    # and the ">>>" will be replaced by the complex comment suffix.
    ANY_COMMENT_CODE = <<-EOF.unindent
      /-- One-line comment --/
      Code
      /--
       - Multi-line
       - comment.
      --/
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
      check_split_file(ANY_COMMENT_CODE.gsub("/--", prefix).gsub("--/", suffix).gsub(" -", inner),
                       Configuration::CLASSIFY_SOURCE_CODE.call("any"),
                       Configuration::FORMAT_PRE_COMMENTS,
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

end
