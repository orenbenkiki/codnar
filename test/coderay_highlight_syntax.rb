require "codnar"
require "test/spec"

# Test highlighting syntax using CodeRay.
class TestCodeRayHighlightSyntax < Test::Unit::TestCase

  def test_coderay_lines
    Codnar::CodeRay.lines_to_html([
      { "kind" => "ruby_code", "number" => 1, "indentation" => "",   "payload" => "def foo"  },
      { "kind" => "ruby_code", "number" => 2, "indentation" => "  ", "payload" => "return 1" },
      { "kind" => "ruby_code", "number" => 3, "indentation" => "",   "payload" => "end"      },
    ], "ruby").should == [
      { "kind" => "html", "number" => 1,
        "payload" => <<-EOF.unindent.chomp
          <div class="CodeRay">
            <div class="code"><pre><span style="color:#080;font-weight:bold">def</span> <span style="color:#06B;font-weight:bold">foo</span>
            <span style="color:#080;font-weight:bold">return</span> <span style="color:#00D">1</span>
          <span style="color:#080;font-weight:bold">end</span></pre></div>
          </div>
        EOF
      },
    ]
  end

end
