require "codnar"
require "test/spec"

module Codnar

  # Test highlighting syntax using GVim.
  class TestHighlightSyntax < Test::Unit::TestCase

    def test_ruby
      ruby = <<-EOF.unindent
        def foo
          return bar = baz
        end
      EOF
      Codnar::GVim.syntax_to_html(ruby, "ruby").should == <<-EOF.unindent
        <pre class='highlighted_syntax'>
        <span class="PreProc">def</span> <span class="Identifier">foo</span>
          <span class="Statement">return</span> bar = baz
        <span class="PreProc">end</span>
        </pre>
      EOF
    end

  end

end
