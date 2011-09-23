require "codnar"
require "olag/test"
require "test/spec"

# Test splitting code files.
class TestSplitCode < Test::Unit::TestCase

  include Test::WithErrors
  include Test::WithTempfile

  def test_split_ruby
    splitter = Codnar::Splitter.new(@errors, RUBY_CONFIGURATION)
    path = write_tempfile("ruby.rb", RUBY_FILE)
    chunks = splitter.chunks(path)
    @errors.should == []
    chunks.should == ruby_chunks(path)
  end

protected

  def ruby_chunks(path)
    RUBY_CHUNKS[0].name = path
    RUBY_CHUNKS[1].containers[0] = path
    RUBY_CHUNKS.each { |chunk| chunk.locations[0].file = path }
    return RUBY_CHUNKS
  end

  RUBY_FILE = <<-EOF.unindent.gsub("#!", "#")
    #! This is *rdoc*.
      #! {{{ assignment
      local = $global
        indented
      #! }}}
  EOF

  RUBY_CONFIGURATION = {
    "formatters" => {
      "code" => "Formatter.cast_lines(lines, 'ruby')",
      "comment" => "Formatter.cast_lines(lines, 'rdoc')",
      "ruby" => "GVim.lines_to_html(lines, 'ruby')",
      "rdoc" => "Formatter.markup_lines_to_html(lines, Codnar::RDoc, 'rdoc')",
      "begin_chunk" => "[]",
      "end_chunk" => "[]",
      "nested_chunk" => "Formatter.nested_chunk_lines_to_html(lines)",
      "unindented_html" => "Formatter.unindented_lines_to_html(lines)",
    },
    "syntax" => {
      "start_state" => "ruby",
      "patterns" => {
        "comment" => { "regexp" => "^(\\s*)#\\s*(.*)$" },
        "code" => { "regexp" => "^(\\s*)(.*)$" },
        "begin_chunk" => { "regexp" => "^(\\s*)\\W*\\{\\{\\{\\s*(.*?)\\s*$" },
        "end_chunk" => { "regexp" => "^(\\s*)\\W*\\}\\}\\}\\s*(.*?)\\s*$" },
      },
      "states" => {
        "ruby" => {
          "transitions" => [
            { "pattern" => "begin_chunk" },
            { "pattern" => "end_chunk" },
            { "pattern" => "comment" },
            { "pattern" => "code" },
          ],
        },
      },
    },
  }

  RUBY_CHUNKS = [ {
    "name" => "PATH",
    "locations" => [ "file" => "PATH", "line" => 1 ],
    "containers" => [],
    "contained" => [ "assignment" ],
    "html" => <<-EOF.unindent.chomp, #! ((( html
      <table class='layout'>
      <tr>
      <td class='indentation'>
      <pre></pre>
      </td>
      <td class='html'>
      <div class='rdoc rdoc markup'>
      <p>
      This is <b>rdoc</b>.
      </p>
      </div>
      </td>
      </tr>
      </table>
      <pre class='nested chunk'>
        <a class='nested chunk' href='#assignment'>assignment</a>
      </pre>
    EOF
    #! ))) html
  }, {
    "name" => "assignment",
    "containers" => [ "PATH" ],
    "contained" => [],
    "locations" => [ "file" => "PATH", "line" => 2 ],
    "html" => <<-EOF.unindent.chomp, #! ((( html
      <div class='ruby code syntax' bgcolor="#ffffff" text="#000000">
      <font face="monospace">
      local =&nbsp;<font color="#00ffff">$global</font><br />
      &nbsp;&nbsp;indented<br />
      </font>
      </div>
    EOF
    #! ))) html
  } ]

end
