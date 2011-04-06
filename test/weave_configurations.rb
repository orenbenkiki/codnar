require "codnar"
require "test/spec"
require "with_fakefs"

module Codnar

  # Test the built-in weave configurations.
  class TestWeaveConfigurations < TestWithFakeFS

    def test_weave_file
      Writer.write("chunks", {
        "locations" => [ "file" => "chunk" ], "containers" => [], "contained" => [],
        "name" => "Top", "html" => <<-EOF.unindent,
          <h1>Top</h1>
          <embed src="path" type="x-codnar/file"/>
        EOF
      })
      File.open("path", "w") { |file| file.puts("<h2>File</h2>") }
      html = Weaver.new(@errors, [ "chunks" ], Configuration::WEAVE_INCLUDE).weave("include", "top")
      @errors.should == []
      html.should == <<-EOF.unindent
        <h1>Top</h1>
        <h2>File</h2>
      EOF
    end

    def test_weave_include
      Writer.write("chunks", chunks("include"))
      html = Weaver.new(@errors, [ "chunks" ], Configuration::WEAVE_INCLUDE).weave("include", "top")
      @errors.should == []
      html.should == <<-EOF.unindent #! ((( html
        <h1>Top</h1>
        <h2>Intermediate</h2>
        <h3>Bottom</h3>
      EOF
      #! ))) html
    end

    WOVEN_PLAIN_CHUNK = <<-EOF.unindent #! ((( html
      <div class="plain chunk">
      <a name="top"/>
      <h1>Top</h1>
      <div class="plain chunk">
      <a name="intermediate"/>
      <h2>Intermediate</h2>
      <div class="plain chunk">
      <a name="bottom"/>
      <h3>Bottom</h3>
      </div>
      </div>
      </div>
    EOF
    #! ))) html

    def test_weave_plain_chunk
      Writer.write("chunks", chunks("plain_chunk"))
      html = Weaver.new(@errors, [ "chunks" ], Configuration::WEAVE_PLAIN_CHUNK).weave("plain_chunk", "top")
      @errors.should == []
      html.should == WOVEN_PLAIN_CHUNK
    end

    # Normally, one does not nest named_chunk_with_containers chunks this
    # way, but it serves as a test.
    WOVEN_NAMED_CHUNK = <<-EOF.unindent #! ((( html
      <div class="named_with_containers chunk">
      <div class="chunk name">
      <a name="top">
      <span>Top</span>
      </a>
      </div>
      <div class="chunk html">
      <h1>Top</h1>
      <div class="named_with_containers chunk">
      <div class="chunk name">
      <a name="intermediate">
      <span>Intermediate</span>
      </a>
      </div>
      <div class="chunk html">
      <h2>Intermediate</h2>
      <div class="named_with_containers chunk">
      <div class="chunk name">
      <a name="bottom">
      <span>BOTTOM</span>
      </a>
      </div>
      <div class="chunk html">
      <h3>Bottom</h3>
      </div>
      <div class="chunk containers">
      <span class="chunk containers header">Contained in:</span>
      <ul class="chunk containers">
      <li class="chunk container">
      <a class="chunk container" href="#intermediate">Intermediate</a>
      </li>
      </ul>
      </div>
      </div>
      </div>
      <div class="chunk containers">
      <span class="chunk containers header">Contained in:</span>
      <ul class="chunk containers">
      <li class="chunk container">
      <a class="chunk container" href="#top">Top</a>
      </li>
      </ul>
      </div>
      </div>
      </div>
      </div>
    EOF
    #! ))) html

    def test_weave_named_chunk_with_containers
      Writer.write("chunks", chunks("named_chunk_with_containers"))
      html = Weaver.new(@errors, [ "chunks" ], Configuration::WEAVE_NAMED_CHUNK_WITH_CONTAINERS).weave("named_chunk_with_containers", "top")
      @errors.should == []
      html.should == WOVEN_NAMED_CHUNK
    end

  protected

    def chunks(template)
      return [ {
        "locations" => [ "file" => "chunk" ], "containers" => [ "Intermediate" ], "contained" => [], "name" => "BOTTOM", "html" => "<h3>Bottom</h3>\n",
      }, {
        "locations" => [ "file" => "chunk" ], "containers" => [ "Top" ], "contained" => [ "BOTTOM" ],
        "name" => "Intermediate", "html" => <<-EOF.unindent, #! ((( html
          <h2>Intermediate</h2>
          <embed type='x-codnar/#{template}' src='bottom'>
          </embed>
        EOF
        #! ))) html
      }, {
        "locations" => [ "file" => "chunk" ], "containers" => [], "contained" => [ "Intermediate" ],
        "name" => "Top", "html" => <<-EOF.unindent, #! ((( html
          <h1>Top</h1>
          <embed src="##INTERMEDIATE" type="x-codnar/#{template}"/>
        EOF
        #! ))) html
      } ]
    end

  end

end
