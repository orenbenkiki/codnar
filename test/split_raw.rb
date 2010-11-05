require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test "splitting" raw HTML documentation files.
  class TestSplitRaw < Test::Unit::TestCase

    def setup
      @errors = Errors.new
      FakeFS.activate!
      FakeFS::FileSystem.clear
    end

    def teardown
      FakeFS.deactivate!
    end

    def test_split_raw
      File.open("raw.html", "w") { |file| file.write("<foo>\nbar\n</foo>\n") }
      splitter = Splitter.new(@errors, CONFIGURATION)
      splitter.chunks("raw.html").should == [ {
        "name" => "raw.html",
        "locations" => [ { "file" => "raw.html", "line" => 1 } ],
        "html" => "<foo>\nbar\n</foo>\n"
      } ]
      @errors.should == []
    end

    CONFIGURATION = {
      "syntax" => {
        "start_state" => "html",
        "patterns" => {
          "html" => { "regexp" => "^", "groups" => [] },
        },
        "states" => {
          "html" => {
            "transitions" => [
              { "pattern" => "html", "next_state" => "html" }
            ]
          }
        }
      }
    }

  end

end
