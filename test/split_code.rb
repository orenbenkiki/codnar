require "codnar"
require "test/spec"
require "fakefs/safe"

module Codnar

  # Test splitting code files.
  class TestSplitCode < Test::Unit::TestCase

    def test_split_ruby
      errors = Errors.new
      splitter = Splitter.new(errors, RUBY_CONFIGURATION)
      path = write_ruby_file
      splitter.chunks(path).should == ruby_chunks(path)
      errors.should == []
    end

  protected

    def write_ruby_file
      file = Tempfile.open("ruby.rb")
      file.write(RUBY_FILE)
      file.close(false)
      return file.path
    end

    def ruby_chunks(path)
      RUBY_CHUNKS[0].name = path
      RUBY_CHUNKS.each { |chunk| chunk.locations[0].file = path }
      return RUBY_CHUNKS
    end

    RUBY_FILE = <<-EOF.unindent
      # This is *rdoc*.
        # {{{ assignment
        local = $global
        # }}}
    EOF

    RUBY_CONFIGURATION = {
      "formatters" => {
        "ruby" => "GVim.lines_to_html(lines, 'ruby')",
        "rdoc" => "Formatter.markup_to_html(lines, 'RDoc')",
        "begin_chunk" => "[]",
        "end_chunk" => "[]",
        "nested_chunk" => "Formatter.nested_chunk_lines_to_html(lines)",
      },
      "syntax" => {
        "start_state" => "ruby",
        "patterns" => {
          "rdoc" => { "regexp" => "^(\\s*)#\\s*(.*)$", "groups" => [ "indentation", "payload" ] },
          "ruby" => { "regexp" => "^(\\s*)(.*)$", "groups" => [ "indentation", "payload" ] },
          "begin_chunk" => { "regexp" => "^(\\s*)\\W*\\{\\{\\{\\s*(.*?)\\s*$", "groups" => [ "indentation", "payload" ] },
          "end_chunk" => { "regexp" => "^(\\s*)\\W*\\}\\}\\}\\s*(.*?)\\s*$", "groups" => [ "indentation", "payload" ] },
        },
        "states" => {
          "ruby" => {
            "transitions" => [
              { "pattern" => "begin_chunk" },
              { "pattern" => "end_chunk" },
              { "pattern" => "rdoc" },
              { "pattern" => "ruby" },
            ],
          },
        },
      },
    }

    RUBY_CHUNKS = [ {
      "name" => "PATH",
      "locations" => [ "file" => "PATH", "line" => 1 ],
      "html" => <<-EOF.unindent,
        <div class='rdoc'>
        <p>
        This is <b>rdoc</b>.
        </p>
        </div>
        <pre class='nested_chunk'>
          <a href='assignment'>assignment</a>
        </pre>
      EOF
    }, {
      "name" => "assignment",
      "locations" => [ "file" => "PATH", "line" => 2 ],
      "html" => <<-EOF.unindent,
        <pre class='highlighted_syntax'>
        local = <span class=\"Identifier\">$global</span>
        </pre>
      EOF
    } ]

  end

end
