require "test_case"

module Codnar

  # Tests that collect Errors.
  class TestWithErrors < TestCase

    def setup
      super
      @errors = Errors.new
    end

  end

end
