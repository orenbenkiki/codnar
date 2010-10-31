require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test weaving chunks to combined HTML.
  class TestWeaveChunks < Test::Unit::TestCase

    def setup
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_weave_chunks
      Writer::write("all.chunks", [ top_chunk, intermediate_chunk, bottom_chunk ])
      errors = Errors.new
      html = Weaver::new(errors, [ "all.chunks" ]).weave("top")
      errors.should == []
      html.should == <<-EOF.unindent
        <html><body>
        <h1>Top</h1>
        <h2>Intermediate</h2>
        <h3>Bottom</h3>
        </html></body>
      EOF
    end

    def top_chunk
      return {
        "name" => "Top",
        "html" => <<-EOF.unindent
          <html><body>
          <h1>Top</h1>
          <script src="##INTERMEDIATE" type="x-codnar/include"></script>
          </html></body>
        EOF
      }
    end
    
    def intermediate_chunk
      return {
        "name" => "Intermediate",
        "html" => <<-EOF.unindent
          <h2>Intermediate</h2>
          <script type='x-codnar/include' src='bottom'>
          </script>
        EOF
      }
    end
    
    def bottom_chunk
      return {
        "name" => "BOTTOM",
        "html" => "<h3>Bottom</h3>\n"
      }
    end

  end

end
