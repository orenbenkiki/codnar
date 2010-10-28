require "codnar"
require "test/spec"

# Test collecting errors.
class TestCollectErrors < Test::Unit::TestCase

  def setup
    @errors = Codnar::Errors.new
  end

  def test_one_error
    @errors << "Oops!"
    @errors.should == [ "#{$0}: Oops!" ]
  end

  def test_path_error
    @errors.in_path("foo") do
      @errors << "Eeek!"
    end
    @errors << "Oops!"
    @errors.should == [ "foo: Eeek!", "#{$0}: Oops!" ]
  end

  def test_line_error
    @errors.in_path("foo") do
      @errors.at_line(1)
      @errors << "Eeek!"
    end
    @errors << "Oops!"
    @errors.should == [ "foo(1): Eeek!", "#{$0}: Oops!" ]
  end

end
