require "codnar/rake"
require "olag/test"
require "test/spec"

# Test rake tasks.
class TestRakeTasks < Test::Unit::TestCase

  include Test::WithFakeFS
  include Test::WithRake

  def test_default
    run_rake
    test_results
  end

protected

  def run_rake
    File.open("foo", "w") { |file| file.puts("foo") }
    Codnar::Rake::SplitTask.new([ "foo" ], [])
    Codnar::Rake::WeaveTask.new("foo", [])
    @rake["codnar"].invoke
  end

  def test_results
    chunk_file = Codnar::Rake.chunks_dir + "/foo"
    YAML.load_file(chunk_file).should == [ {
      "html" => "foo",
      "name" => "foo",
      "locations" => [ { "file" => "foo", "line" => 1 } ],
      "containers" => [],
      "contained" => [],
    } ]
    File.read("codnar.html").should == "foo\n"
    Codnar::Rake.chunk_files.should == [ chunk_file ]
  end

end
