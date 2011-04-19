require "codnar"
require "test/spec"

# Test highlighting syntax using GVim.
class TestGVimHighlightSyntax < Test::Unit::TestCase

  def setup
    Codnar::GVim.force_recompute = true
  end

  def teardown
    Codnar::GVim.force_recompute = false
  end

  def test_ruby_no_css
    ruby = <<-EOF.unindent
      def foo
        return bar = baz
      end
    EOF
    Codnar::GVim.cached_syntax_to_html(ruby, "ruby").should == <<-EOF.unindent #! ((( html
      <div class='ruby code syntax' bgcolor="#ffffff" text="#000000">
      <font face="monospace">
      <font color="#ff40ff">def</font>&nbsp;<font color="#00ffff">foo</font><br />
      &nbsp;&nbsp;<font color="#ffff00">return</font>&nbsp;bar = baz<br />
      <font color="#ff40ff">end</font><br />
      </font>
      </div>
    EOF
    #! ))) html
  end

  def test_ruby_css
    ruby = <<-EOF.unindent
      def foo
        return bar = baz
      end
    EOF
    Codnar::GVim.cached_syntax_to_html(ruby, "ruby", [ "+:let html_use_css=1" ]).should == <<-EOF.unindent #! ((( html
      <pre class='ruby code syntax'>
      <span class="PreProc">def</span> <span class="Identifier">foo</span>
        <span class="Statement">return</span> bar = baz
      <span class="PreProc">end</span>
      </pre>
    EOF
    #! ))) html
  end

end
