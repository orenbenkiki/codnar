require "codnar"
require "test/spec"
require "with_fakefs"

module Codnar

  # Test the built-in weave configurations.
  class TestWeaveConfigurations < Test::Unit::TestCase

    include WithFakeFS

    def test_weave_include
      Writer.write("chunks", chunks("include"))
      errors = Errors.new
      html = Weaver.new(errors, [ "chunks" ], Configuration::WEAVE_INCLUDE).weave("top", "include")
      errors.should == []
      html.should == <<-EOF.unindent
        <h1>Top</h1>
        <h2>Intermediate</h2>
        <h3>Bottom</h3>
      EOF
    end

    WOVEN_PLAIN_CHUNK = <<-EOF.unindent
      <a class="plain chunk" name="top">
      <h1>Top</h1>
      <a class="plain chunk" name="intermediate">
      <h2>Intermediate</h2>
      <a class="plain chunk" name="bottom">
      <h3>Bottom</h3>
      </a>
      </a>
      </a>
    EOF

    def test_weave_plain_chunk
      Writer.write("chunks", chunks("plain_chunk"))
      errors = Errors.new
      html = Weaver.new(errors, [ "chunks" ], Configuration::WEAVE_PLAIN_CHUNK).weave("top", "plain_chunk")
      errors.should == []
      html.should == WOVEN_PLAIN_CHUNK
    end

    WOVEN_NAMED_CHUNK = <<-EOF.unindent
      <a class="named_with_containers chunk" name="top">
      <span class="chunk name">Top</span>
      <div class="chunk html">
      <h1>Top</h1>
      <a class="named_with_containers chunk" name="intermediate">
      <span class="chunk name">Intermediate</span>
      <div class="chunk html">
      <h2>Intermediate</h2>
      <a class="named_with_containers chunk" name="bottom">
      <span class="chunk name">BOTTOM</span>
      <div class="chunk html">
      <h3>Bottom</h3>
      </div>
      </a>
      </div>
      <div class="chunk containers">
      <span class="chunk containers header">Contained in:</span>
      <ul class="chunk containers">
      <li class="chunk container"><a class="chunk container" href="#top">Top</a></li>
      </ul>
      </div>
      </a>
      </div>
      <div class="chunk containers">
      <span class="chunk containers header">Contained in:</span>
      <ul class="chunk containers">
      <li class="chunk container"><a class="chunk container" href="#intermediate">Intermediate</a></li>
      </ul>
      </div>
      </a>
    EOF

    def test_weave_named_chunk_with_containers
      Writer.write("chunks", chunks("named_chunk_with_containers"))
      errors = Errors.new
      html = Weaver.new(errors, [ "chunks" ], Configuration::WEAVE_NAMED_CHUNK_WITH_CONTAINERS).weave("top", "named_chunk_with_containers")
      errors.should == []
      html.should == WOVEN_NAMED_CHUNK
    end

  protected

    def chunks(template)
      return [ {
        "locations" => [ "file" => "chunk" ], "containers" => [], "contained" => [ "Intermediate" ], "name" => "BOTTOM", "html" => "<h3>Bottom</h3>\n",
      }, {
        "locations" => [ "file" => "chunk" ], "containers" => [ "Top" ], "contained" => [ "BOTTOM" ],
        "name" => "Intermediate", "html" => <<-EOF.unindent,
          <h2>Intermediate</h2>
          <script type='x-codnar/#{template}' src='bottom'>
          </script>
        EOF
      }, {
        "locations" => [ "file" => "chunk" ], "containers" => [ "Intermediate" ], "contained" => [],
        "name" => "Top", "html" => <<-EOF.unindent,
          <h1>Top</h1>
          <script src="##INTERMEDIATE" type="x-codnar/#{template}"></script>
        EOF
      } ]
    end

  end

end
