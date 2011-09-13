require "codnar"
require "test/spec"

# Test highlighting syntax using GVim.
class TestGraphVizDiagrams < Test::Unit::TestCase

  MINIMAL_DIAGRAM_SVG = <<-EOF.unindent #! ((( svg
    <svg width="62pt" height="116pt"
     viewBox="0.00 0.00 62.00 116.00" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="graph1" class="graph" transform="scale(1 1) rotate(0) translate(4 112)">
    <title>_anonymous_0</title>
    <polygon fill="white" stroke="white" points="-4,5 -4,-112 59,-112 59,5 -4,5"/>
    <!-- A -->
    <g id="node1" class="node"><title>A</title>
    <ellipse fill="none" stroke="black" cx="27" cy="-90" rx="27" ry="18"/>
    <text text-anchor="middle" x="27" y="-85.4" font-family="Times New Roman,serif" font-size="14.00">A</text>
    </g>
    <!-- B -->
    <g id="node3" class="node"><title>B</title>
    <ellipse fill="none" stroke="black" cx="27" cy="-18" rx="27" ry="18"/>
    <text text-anchor="middle" x="27" y="-13.4" font-family="Times New Roman,serif" font-size="14.00">B</text>
    </g>
    <!-- A&#45;&gt;B -->
    <g id="edge2" class="edge"><title>A&#45;&gt;B</title>
    <path fill="none" stroke="black" d="M27,-71.8314C27,-64.131 27,-54.9743 27,-46.4166"/>
    <polygon fill="black" stroke="black" points="30.5001,-46.4132 27,-36.4133 23.5001,-46.4133 30.5001,-46.4132"/>
    </g>
    </g>
    </svg>
  EOF
  #! ))) svg

  def test_valid_diagram
    diagram = <<-EOF.unindent #! ((( dot
      define(`X', `A')
      digraph {
        X -> B;
      }
    EOF
    #! ))) dot
    Codnar::GraphViz.to_html(diagram).should == MINIMAL_DIAGRAM_SVG
  end

  def test_invalid_diagram
    diagram = <<-EOF.unindent #! ((( dot
      digraph {
        A ->
    EOF
    #! ))) dot
    lambda { Codnar::GraphViz.to_html(diagram) }.should.raise
  end

end
