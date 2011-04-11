require "codnar"
require "test/spec"
require "test_with_errors"

module Codnar

  # Test collecting errors.
  class TestCollectErrors < Test::Unit::TestCase

    include TestWithErrors

    def test_one_error
      @errors << "Oops"
      @errors.should == [ "#{$0}: Oops" ]
    end

    def test_path_error
      @errors.in_path("foo") do
        @errors << "Eeek"
      end
      @errors << "Oops"
      @errors.should == [ "#{$0}: Eeek in file: foo", "#{$0}: Oops" ]
    end

    def test_line_error
      @errors.in_path("foo") do
        @errors.at_line(1)
        @errors << "Eeek"
      end
      @errors << "Oops"
      @errors.should == [ "#{$0}: Eeek in file: foo at line: 1", "#{$0}: Oops" ]
    end

  end

end
