require "codnar"
require "test/spec"
require "fakefs/safe"

# Test writing chunks to files.
class TestWriteChunks < Test::Unit::TestCase

  def setup
    FakeFS.activate!
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_write_chunks
    check_write_data([])
    check_write_data("name" => "foo")
    check_write_data([ { "name" => "foo" }, { "name" => "bar" } ])
  end

  def test_write_invalid_data
    lambda { check_write_data("not a chunk") }.should.raise
  end

  def check_write_data(data)
    Codnar::Chunk::Writer::new("path") do |writer|
      writer << data
    end
    data = [ data ] unless Array === data
    YAML.load_file("path").should == data
  end

end
