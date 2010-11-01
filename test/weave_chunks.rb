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
      Writer::write("chunks", CHUNKS)
      errors = Errors.new
      html = Weaver::new(errors, [ "chunks" ]).weave("top")
      errors.should == []
      html.should == <<-EOF.unindent
        <html><body>
        <h1>Top</h1>
        <h2>Intermediate</h2>
        <h3>Bottom</h3>
        </html></body>
      EOF
    end

  protected

    CHUNKS = [ {
      "name" => "BOTTOM",
      "html" => "<h3>Bottom</h3>\n"
    }, {
      "name" => "Intermediate", "html" => <<-EOF.unindent
        <h2>Intermediate</h2>
        <script type='x-codnar/include' src='bottom'>
        </script>
      EOF
    }, {
      "name" => "Top",
      "html" => <<-EOF.unindent
        <html><body>
        <h1>Top</h1>
        <script src="##INTERMEDIATE" type="x-codnar/include"></script>
        </html></body>
      EOF
    } ]

  end

end
