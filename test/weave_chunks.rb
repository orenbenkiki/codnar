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
      Writer.write("chunks", CHUNKS)
      errors = Errors.new
      html = Weaver.new(errors, [ "chunks" ], {
        "wrap_in_div" => "<div>\n<%= chunk.expanded_html %>\n</div>\n"
      }).weave("top", "include")
      errors.should == [ "#{$0}: Missing ERB template: include in file: chunk" ]
      html.should == <<-EOF.unindent
        <html><body>
        <h1>Top</h1>
        <h2>Intermediate</h2>
        <div>
        <h3>Bottom</h3>
        </div>
        </html></body>
      EOF
    end

  protected

    CHUNKS = [ {
      "name" => "BOTTOM",
      "locations" => [ "file" => "chunk" ],
      "html" => "<h3>Bottom</h3>\n",
    }, {
      "name" => "Intermediate",
      "locations" => [ "file" => "chunk" ],
      "html" => <<-EOF.unindent
        <h2>Intermediate</h2>
        <script type='x-codnar/wrap_in_div' src='bottom'>
        </script>
      EOF
    }, {
      "name" => "Top",
      "locations" => [ "file" => "chunk" ],
      "html" => <<-EOF.unindent
        <html><body>
        <h1>Top</h1>
        <script src="##INTERMEDIATE" type="x-codnar/include"></script>
        </html></body>
      EOF
    } ]

  end

end
