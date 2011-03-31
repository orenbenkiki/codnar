module Codnar

  # Tests with additional utilities.
  class TestCase < Test::Unit::TestCase

    def test_nothing
      # Shuts test-spec about "no tests" in this base class.
    end

  protected

    # Create a temporary file on the disk. There's no need to clean it up since
    # most times we'll be using FakeFS.
    def write_tempfile(path, content)
      file = Tempfile.open(path)
      file.write(content)
      file.close(false)
      return file.path
    end

  end

end
