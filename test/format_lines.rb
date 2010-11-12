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
        { "kind" => "html", "number" => 1, "payload" => "foo", },
        { "kind" => "html", "number" => 2, "payload" => "bar", },
        { "kind" => "html", "number" => 3, "payload" => "baz", },
      ]).should == [ { "kind" => "html", "number" => 1, "payload" => "foo\nbar\nbaz" } ]
      @errors.should == []
    end

    def test_process_unknown_lines
      @formatter.process_lines_group([
        { "kind" => "unknown-kind", "number" => 1, "payload" => "<foo>", },
      ]).should == [ { "kind" => "html", "number" => 1, "payload" => "<pre class='missing_formatter'>\n&lt;foo&gt;\n</pre>" } ]
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
    end

    def test_process_code_lines
      @formatter.process_lines_group([
        { "kind" => "code", "number" => 1, "payload" => "<foo>", },
        { "kind" => "code", "number" => 2, "payload" => "bar", },
      ]).should == [ { "kind" => "html", "number" => 1, "payload" => "<pre>\n&lt;foo&gt;\nbar\n</pre>" } ]
      @errors.should == []
    end

    def test_failed_formatter
      @formatter.process_lines_group([
        { "kind" => "fail", "number" => 1, "payload" => "foo", },
      ]).should == [ { "kind" => "html", "number" => 1, "payload" => "<pre class='failed_formatter'>\nfoo\n</pre>" } ]
      @errors.size.should == 1
      error_should = @errors.last.should
      error_should.include?("#{$0}: Formatter: TestFormatLines.fail for lines of kind: fail failed with exception: ")
      error_should.include?("in `fail': Reason")
    end

    def test_lines_to_html
      @formatter.lines_to_html([
        { "kind" => "html", "number" => 1, "payload" => "foo" },
        { "kind" => "code", "number" => 2, "payload" => "<bar>" },
        { "kind" => "html", "number" => 3, "payload" => "baz" },
      ]).should == "foo\n<pre>\n&lt;bar&gt;\n</pre>\nbaz"
      @errors.should == []
    end

    def self.fail
      raise "Reason"
    end

  end

end
