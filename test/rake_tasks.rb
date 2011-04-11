require "codnar/rake"
require "test/spec"
require "test_with_fakefs"

module Codnar

  # Test rake tasks.
  class TestRakeTasks < Test::Unit::TestCase

    include TestWithFakeFS

    alias_method :original_setup, :setup

    def setup
      original_setup 
      @original_rake = ::Rake.application
      @rake = ::Rake::Application.new
      ::Rake.application = @rake
    end

    def teardown
      super
      ::Rake.application = @original_rake
    end

    def test_default
      run_rake
      test_results
    end

  protected

    def run_rake
      File.open("foo", "w") { |file| file.puts("foo") }
      Rake::SplitTask.new([ "foo" ], [])
      Rake::WeaveTask.new("foo", [])
      @rake["codnar"].invoke
    end

    def test_results
      chunk_file = Rake.chunks_dir + "/foo"
      YAML.load_file(chunk_file).should == [ {
        "html" => "foo",
        "name" => "foo",
        "locations" => [ { "file" => "foo", "line" => 1 } ],
        "containers" => [],
        "contained" => [],
      } ]
      File.read("codnar.html").should == "foo\n"
      Rake.chunk_files.should == [ chunk_file ]
    end

  end

end
