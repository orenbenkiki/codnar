module Codnar

  # Setup tests that collect Errors.
  module WithErrors

    def setup
      @errors = Errors.new
    end

  end

end
