require "codnar"
require "test/spec"
require "fakefs/safe"

# Test reading chunks from files.
class TestReadChunks < Test::Unit::TestCase

  def setup
    FakeFS.activate!
    @errors = Codnar::Errors.new
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_read_chunks
    Codnar::Chunk::Writer::write("foo.chunks", { "name" => "foo" })
    Codnar::Chunk::Writer::write("bar.chunks", [ { "name" => "bar" }, { "name" => "baz" } ])
    reader = Codnar::Chunk::Reader::new(@errors, Dir.glob("./**/*.chunks"))
    check_read_data(reader,  "foo" => { "name" => "foo" },
                             "bar" => { "name" => "bar" },
                             "baz" => { "name" => "baz" })
    @errors.should == []
  end

  def test_read_fake_chunk
    reader = Codnar::Chunk::Reader::new(@errors, [])
    reader["foo"].name.should == "foo"
    @errors.should == [ "#{$0}: Missing chunk: foo" ]
  end

  def check_read_data(reader, chunks)
    chunks.each do |name, chunk|
      reader[name].should == chunk
    end
  end

end
