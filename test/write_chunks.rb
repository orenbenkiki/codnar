require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test writing chunks to files.
  class TestWriteChunks < Test::Unit::TestCase

    def setup
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_write_chunks
      check_writing_data([])
      check_writing_data("name" => "foo")
      check_writing_data([ { "name" => "foo" }, { "name" => "bar" } ])
    end

    def test_write_invalid_data
      lambda { check_writing_data("not a chunk") }.should.raise
    end

    def check_writing_data(data)
      Writer::write("path", data)
      data = [ data ] unless Array === data
      YAML.load_file("path").should == data
    end

  end

end
