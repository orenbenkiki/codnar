require "codnar"
require "olag/test"
require "test/spec"
require "test_with_configurations"

# Test combination of many built-in configurations.
class TestSplitCombinedConfigurations < Test::Unit::TestCase

  include Test::WithConfigurations
  include Test::WithErrors
  include Test::WithTempfile

  CODE_TEXT = <<-EOF.unindent.gsub("#!", "#")
    #!!/usr/bin/ruby -w

    #! {{{ HTML snippet

    HELLO_WORLD_IN_HTML = <<-EOH.unindent.chomp #! ((( html
      <p>
      Hello, world!
      </p>
    EOH
    #! ))) html

    #! }}}

    #! {{{ Ruby code

    #! Hello, *world*!
    puts HELLO_WORLD_IN_HTML

    #! }}}
  EOF

  FILE_HTML = <<-EOF.unindent.chomp
    <pre class='ruby code syntax'>
    <span class="PreProc">#!/usr/bin/ruby -w</span>

    </pre>
    <pre class='nested chunk'>
    <a class='nested chunk' href='#html-snippet'>HTML snippet</a>
    </pre>
    <pre class='ruby code syntax'>

    </pre>
    <pre class='nested chunk'>
    <a class='nested chunk' href='#ruby-code'>Ruby code</a>
    </pre>
  EOF

  HTML_CHUNK = <<-EOF.unindent.chomp
    <pre class='ruby code syntax'>

    <span class="Type">HELLO_WORLD_IN_HTML</span> = &lt;&lt;-<span class="Special">EOH</span>.unindent.chomp <span class="Comment"># ((( html</span>
    </pre>
    <pre class='html code syntax'>
      <span class="Identifier">&lt;</span><span class="Statement">p</span><span class="Identifier">&gt;</span>
      Hello, world!
      <span class="Identifier">&lt;/</span><span class="Statement">p</span><span class="Identifier">&gt;</span>
    EOH
    </pre>
    <pre class='ruby code syntax'>
    <span class="Comment"># ))) html</span>

    </pre>
  EOF

  RUBY_CHUNK = <<-EOF.unindent.chomp
    <pre class='ruby code syntax'>

    </pre>
    <table class='layout'>
    <tr>
    <td class='indentation'>
    <pre></pre>
    </td>
    <td class='html'>
    <div class='rdoc comment markup'>
    <p>
    Hello, <b>world</b>!
    </p>
    </div>
    </td>
    </tr>
    </table>
    <pre class='ruby code syntax'>
    puts <span class="Type">HELLO_WORLD_IN_HTML</span>

    </pre>
  EOF

  def test_gvim_chunks
    check_split_file(CODE_TEXT,
                     Codnar::Configuration::CLASSIFY_SOURCE_CODE.call("ruby"),
                     Codnar::Configuration::FORMAT_CODE_GVIM_CSS.call("ruby"),
                     Codnar::Configuration::CLASSIFY_NESTED_CODE.call("ruby", "html"),
                     Codnar::Configuration::FORMAT_CODE_GVIM_CSS.call("html"),
                     Codnar::Configuration::CLASSIFY_SHELL_COMMENTS.call,
                     Codnar::Configuration::FORMAT_RDOC_COMMENTS,
                     Codnar::Configuration::CHUNK_BY_VIM_REGIONS) do |path|
      [ {
        "name" => path, "html" => FILE_HTML,
        "locations" => [ { "line" => 1, "file" => path } ], "containers" => [], "contained" => [ "HTML snippet", "Ruby code" ],
      }, {
        "name" => "HTML snippet", "html" => HTML_CHUNK,
        "locations" => [ { "line" => 3, "file" => path } ], "containers" => [ path ], "contained" => [],
      }, {
        "name" => "Ruby code", "html" => RUBY_CHUNK,
        "locations" => [ { "line" => 14, "file" => path } ], "containers" => [ path ], "contained" => [],
      } ]
    end
  end

end
