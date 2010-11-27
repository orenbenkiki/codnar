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
      lines_group = @formatter.process_lines_group([
        { "kind" => "html", "number" => 1, "payload" => "foo", },
        { "kind" => "html", "number" => 2, "payload" => "bar", },
        { "kind" => "html", "number" => 3, "payload" => "baz", },
      ])
      @errors.should == []
      lines_group.should == [ { "kind" => "html", "number" => 1, "payload" => "foo\nbar\nbaz" } ]
    end

    def test_process_unknown_lines
      lines_group = @formatter.process_lines_group([
        { "kind" => "unknown-kind", "number" => 1, "payload" => "<foo>", },
      ])
      @errors.should == [ "#{$0}: No formatter specified for lines of kind: unknown-kind" ]
      lines_group.should == [ { "kind" => "html", "number" => 1, "payload" => "<pre class='missing formatter error'>\n&lt;foo&gt;\n</pre>" } ]
    end

    def test_process_code_lines
      lines_group = @formatter.process_lines_group([
        { "kind" => "code", "number" => 1, "payload" => "<foo>", },
        { "kind" => "code", "number" => 2, "payload" => "bar", },
      ])
      @errors.should == []
      lines_group.should == [ { "kind" => "html", "number" => 1, "payload" => "<pre>\n&lt;foo&gt;\nbar\n</pre>" } ]
    end

    def test_failed_formatter
      lines_group = @formatter.process_lines_group([ { "kind" => "fail", "number" => 1, "payload" => "foo", } ])
      @errors.size.should == 1
      @errors.last.should =~ /#{$0}: Formatter: TestFormatLines.fail for lines of kind: fail failed with exception:.*in `fail': Reason/
      lines_group.should == [ { "kind" => "html", "number" => 1, "payload" => "<pre class='failed formatter error'>\nfoo\n</pre>" } ]
    end

    def test_lines_to_html
      lines_group = @formatter.lines_to_html([
        { "kind" => "html", "number" => 1, "payload" => "foo" },
        { "kind" => "code", "number" => 2, "payload" => "<bar>" },
        { "kind" => "html", "number" => 3, "payload" => "baz" },
      ])
      @errors.should == []
      lines_group.should == "foo\n<pre>\n&lt;bar&gt;\n</pre>\nbaz"
    end

    def self.fail
      raise "Reason"
    end

  end

end
