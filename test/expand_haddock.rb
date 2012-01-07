require "codnar"
require "test/spec"

# Test expanding Haddock text.
class TestExpandHaddock < Test::Unit::TestCase

  def test_normal_text
    Codnar::Haddock.to_html("normal").should == "<p>normal\n</p>\n"
  end

  def test_identifier_text
    Codnar::Haddock.to_html("'Int'").should == "<p><code>Int</code>\n</p>\n"
  end

  def test_emphasis_text
    Codnar::Haddock.to_html("/emphasis/").should == "<p><em>emphasis</em>\n</p>\n"
  end

  def test_code_text
    Codnar::Haddock.to_html("@code@").should == "<pre>code</pre>\n"
  end

end
