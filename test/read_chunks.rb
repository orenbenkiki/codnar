require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar::Chunk

  # Test reading chunks from files.
  class TestReadChunks < Test::Unit::TestCase

    def setup
      @errors = Codnar::Errors.new
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_read_chunks
      Writer::write("foo.chunks", { "name" => "foo" })
      Writer::write("bar.chunks", [ { "name" => "bar" }, { "name" => "baz" } ])
      reader = Reader::new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader,  "foo" => { "name" => "foo" },
                               "bar" => { "name" => "bar" },
                               "baz" => { "name" => "baz" })
      @errors.should == []
    end

    def test_read_duplicate_chunks
      Writer::write("foo.chunks", { "name" => "foo", "locations" => [ "a" ] })
      Writer::write("bar.chunks", [ { "name" => "foo", "locations" => [ "b" ] }, { "name" => "foo", "locations" => [ "c" ] } ])
      reader = Reader::new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader,  "foo" => { "name" => "foo", "locations" => [ "b", "c", "a" ] })
    end

    def test_read_different_chunks
      Writer::write("foo.chunks", [
        { "name" => "foo", "content" => "bar", "locations" => [ { "file" => "foo.chunks", "line" => 1 } ] },
        { "name" => "foo", "content" => "baz", "locations" => [ { "file" => "foo.chunks", "line" => 2 } ] }
      ])
      Writer::write("bar.chunks",
        { "name" => "foo", "content" => "bar", "locations" => [ { "file" => "bar.chunks", "line" => 1 } ] })
      reader = Reader::new(@errors, Dir.glob("./**/*.chunks").sort)
      @errors.should == [ "Chunk: foo is different in file: foo.chunks at line: 2, and in file: bar.chunks at line: 1 or in file: foo.chunks at line: 1" ]
      check_read_data(reader, "foo" => {
        "name" => "foo", "content" => "bar", "locations" => [
          { "file" => "bar.chunks", "line" => 1 },
          { "file" => "foo.chunks", "line" => 1 },
        ]
      })
    end

    def test_read_fake_chunk
      reader = Reader::new(@errors, [])
      reader["foo"].name.should == "foo"
      @errors.should == [ "#{$0}: Missing chunk: foo" ]
    end

    def test_read_equivalent_name_chunks
      Writer::write("foo.chunks", [
        { "name" => "Foo?", "locations" => [ { "file" => "foo.chunks", "line" => 1 } ] },
        { "name" => "FOO!!", "locations" => [ { "file" => "foo.chunks", "line" => 2 } ] }
      ])
      reader = Reader::new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader,  "foo-" => {
        "name" => "Foo?",
        "locations" => [
          { "file" => "foo.chunks", "line" => 1 },
          { "file" => "foo.chunks", "line" => 2 }
        ]
      })
    end

    def check_read_data(reader, chunks)
      chunks.each do |name, chunk|
        reader[name].should == chunk
      end
    end

  end

end
