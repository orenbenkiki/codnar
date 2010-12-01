module Codnar

  # Tests with additional utilities.
  class TestCase < Test::Unit::TestCase

    def test_nothing
      # Shuts test-spec about "no tests" in this base class.
    end

  protected

    def write_tempfile(path, content)
      file = Tempfile.open(path)
      file.write(content)
      file.close(false)
      return file.path
    end

  end

end
