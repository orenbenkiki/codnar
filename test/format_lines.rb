require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test converting classified lines to HTML.
  class TestFormatLines < Test::Unit::TestCase

    def setup
      Formatter.send(:public, *Formatter.protected_instance_methods)
      @errors = Errors.new
      @formatter = Formatter.new(@errors, "code" => "Formatter.lines_to_pre_html(lines)", "fail" => "TestFormatLines.fail")
    end

    def test_process_html_lines
      @formatter.process_lines_group([
        { "kind" => "html", "number" => 1, "html" => "foo", },
        { "kind" => "html", "number" => 2, "html" => "bar", },
        { "kind" => "html", "number" => 3, "html" => "baz", },
      ]).should == [ { "kind" => "html", "number" => 1, "html" => "foo\nbar\nbaz" } ]
      @errors.should == []
    end

    def test_process_unknown_lines
      @formatter.process_lines_group([
        { "kind" => "unknown-kind", "number" => 1, "line" => "<foo>", },
      ]).should == [ { "kind" => "html", "number" => 1, "line" => "<foo>", "html" => "<pre>&lt;foo&gt;</pre>" } ]
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
    end

    def test_process_code_lines
      @formatter.process_lines_group([
        { "kind" => "code", "number" => 1, "line" => "<foo>", },
        { "kind" => "code", "number" => 2, "line" => "bar", },
      ]).should == [ { "kind" => "html", "number" => 1, "line" => "<foo>", "html" => "<pre>&lt;foo&gt;\nbar</pre>" } ]
      @errors.should == []
    end

    def test_failed_formatter
      @formatter.process_lines_group([
        { "kind" => "fail", "number" => 1, "line" => "foo", },
      ]).should == [ { "kind" => "html", "number" => 1, "line" => "foo", "html" => "<pre>foo</pre>" } ]
      @errors.size.should == 1
      error_should = @errors.last.should
      error_should.include?("#{$0}: Formatter: TestFormatLines.fail for lines of kind: fail failed with exception: ")
      error_should.include?("in `fail': Reason")
    end

    def test_lines_to_html
      @formatter.lines_to_html([
        { "kind" => "html", "number" => 1, "html" => "foo", },
        { "kind" => "code", "number" => 2, "line" => "<bar>", },
        { "kind" => "html", "number" => 3, "html" => "baz", },
      ]).should == "foo\n<pre>&lt;bar&gt;</pre>\nbaz"
      @errors.should == []
    end

    def self.fail
      raise "Reason"
    end

  end

end
