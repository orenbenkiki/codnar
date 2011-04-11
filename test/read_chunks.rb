require "codnar"
require "test/spec"
require "test_with_errors"
require "test_with_fakefs"

module Codnar

  # Test reading chunks from files.
  class TestReadChunks < Test::Unit::TestCase
  
    include TestWithErrors
    include TestWithFakeFS

    def test_read_chunks
      Writer.write("foo.chunks", { "name" => "foo" })
      Writer.write("bar.chunks", [ { "name" => "bar" }, { "name" => "baz" } ])
      reader = Reader.new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader, "foo" => { "name" => "foo" },
                              "bar" => { "name" => "bar" },
                              "baz" => { "name" => "baz" })
      @errors.should == []
    end

    def test_read_unused_chunks
      Writer.write("foo.chunks", { "name" => "foo",
                                   "locations" => [ { "file" => "a", "line" => 1 } ] })
      Writer.write("bar.chunks", { "name" => "bar",
                                   "locations" => [ { "file" => "b", "line" => 2 } ] })
      reader = Reader.new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader, "foo" => { "name" => "foo",
                                         "locations" => [ { "file" => "a", "line" => 1 } ] })
      @errors.should == [ "#{$0}: Unused chunk: bar in file: b at line: 2" ]
    end

    def test_read_duplicate_chunks
      Writer.write("foo.chunks", { "name" => "foo", "locations" => [ { "file" => "a" } ],
                                   "contained" => [ "A" ], "containers" => [ "c" ] })
      Writer.write("bar.chunks", [
        { "name" => "foo", "locations" => [ { "file" => "b" } ],
          "contained" => [ "a" ], "containers" => [ "d" ] },
        { "name" => "foo", "locations" => [ { "file" => "c" } ],
          "contained" => [ "a" ], "containers" => [] }
      ])
      reader = Reader.new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader, "foo" => {
        "name" => "foo",
        "locations" => [ { "file" => "a" }, { "file" => "b" }, { "file" => "c" } ],
        "contained" => [ "a" ],
        "containers" => [ "c", "d" ],
      })
    end

    def test_read_different_chunks
      Writer.write("foo.chunks", [
        { "name" => "foo", "html" => "bar", "locations" => [ { "file" => "foo.chunks", "line" => 1 } ],
          "contained" => [ "a" ], "containers" => [] },
        { "name" => "foo", "html" => "baz", "locations" => [ { "file" => "foo.chunks", "line" => 2 } ],
          "contained" => [ "A" ], "containers" => [] }
      ])
      Writer.write("bar.chunks", [ { "name" => "foo", "html" => "bar",
                                     "locations" => [ { "file" => "bar.chunks", "line" => 1 } ],
                                     "contained" => [ "a" ], "containers" => [] } ])
      reader = Reader.new(@errors, Dir.glob("./**/*.chunks").sort)
      @errors.should == [ "#{$0}: Chunk: foo is different in file: foo.chunks at line: 2, " \
                        + "and in file: bar.chunks at line: 1 or in file: foo.chunks at line: 1" ]
      check_read_data(reader, "foo" => {
        "name" => "foo",
        "html" => "bar",
        "locations" => [ { "file" => "bar.chunks", "line" => 1 }, { "file" => "foo.chunks", "line" => 1 } ],
        "contained" => [ "a" ],
        "containers" => [],
      })
    end

    def test_read_fake_chunk
      reader = Reader.new(@errors, [])
      reader["foo"].should == Reader.fake_chunk("foo")
      @errors.should == [ "#{$0}: Missing chunk: foo" ]
    end

    def test_read_equivalent_name_chunks
      Writer.write("foo.chunks", [
        { "name" => "Foo?", "locations" => [ { "file" => "foo.chunks", "line" => 1 } ],
          "containers" => [ "1" ], "contained" => [ "c" ] },
        { "name" => "FOO!!", "locations" => [ { "file" => "foo.chunks", "line" => 2 } ],
          "containers" => [ "2" ], "contained" => [ "C" ] }
      ])
      reader = Reader.new(@errors, Dir.glob("./**/*.chunks"))
      check_read_data(reader, "foo-" => {
        "name" => "Foo?",
        "locations" => [ { "file" => "foo.chunks", "line" => 1 }, { "file" => "foo.chunks", "line" => 2 } ],
        "containers" => [ "1", "2" ],
        "contained" => [ "c" ],
      })
    end

  protected

    def check_read_data(reader, chunks)
      chunks.each do |name, chunk|
        reader[name].should == chunk
      end
      reader.collect_unused_chunk_errors
    end

  end

end
