require "codnar"
require "test/spec"

module Codnar

  # Test highlighting syntax using Sunlight.
  class TestSunlightHighlightSyntax < Test::Unit::TestCase

    def test_sunlight_lines
      Sunlight.lines_to_html([
        { "kind" => "ruby_code", "number" => 1, "indentation" => "",   "payload" => "def foo"  },
        { "kind" => "ruby_code", "number" => 2, "indentation" => "  ", "payload" => "return 1" },
        { "kind" => "ruby_code", "number" => 3, "indentation" => "",   "payload" => "end"      },
      ], "ruby").should == [
        { "kind" => "html", "number" => 1,
          "payload" => <<-EOF.unindent.chomp
            <pre class='sunlight-highlight-ruby'>
            def foo
              return 1
            end
            </pre>
          EOF
        },
      ]
    end

  end

end
