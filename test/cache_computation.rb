require "codnar"
require "olag/test"
require "test/spec"

# Test caching long computations.
class TestCacheComputations < Test::Unit::TestCase

  include Test::WithTempfile

  def test_cached_computation
    cache = make_addition_cache(directory = create_tempdir(".."))
    cache[1].should == 2
    File.open(Dir.glob(directory + "/*")[0], "w") { |file| file.puts("3") }
    cache[1].should == 3
    cache.force_recompute = true
    cache[1].should == 2
  end

  def test_uncached_computation
    stderr = capture_stderr { make_addition_cache("no-such-directory")[1].should == 2 }
    stderr.should.include?("no-such-directory")
  end

protected

  # Run a block and capture its standard error (without using FakeFS).
  def capture_stderr
    stderr_path = write_tempfile("stderr", "")
    Olag::Globals.without_changes do
      $stderr = File.open(stderr_path, "w")
      yield
    end
    return File.read(stderr_path)
  end

  # Create a cache for the "+ 1" operation.
  def make_addition_cache(directory)
    return Codnar::Cache.new(directory) { |value| value + 1 }
  end

end
