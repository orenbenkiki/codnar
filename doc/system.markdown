## Splitting files into chunks ##

Codnar makes the reasonable assumption that each source file can be effectively
processed as a sequence of lines. This works well in practice for all "text"
source files. It fails miserably for "binary" source files, but such files
don't work that well in most generic source management tools (such as version
management systems).

A second, less obvious assumption is that it is possible to classify the source
file lines to "kinds" using a simple state machine. The classified lines are
then grouped into nested chunks based on the two special line kinds
`begin_chunk` and `end_chunk`. The other line kinds are used to control how the
lines are formatted into HTML.

The collected chunks, with the formatted HTML for each one, are then stored in
a chunks file to be used later for weaving the overall HTML narrative.

### Scanning Lines ###

Scanning a file into classified lines is done by the `Scanner` class.
Here is a simple test that demonstrates using the scanner:

[[test/scan_lines.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/scanner.rb|named_chunk_with_containers]]

As we can see, the implementation is split into two main parts. First, all
shorthands in the syntax definition are expanded (possibly generating errors).
Then, the expanded syntax is applied to a file, to generate a sequence of
classified lines.

#### Scanner Syntax Shorthands ####

The syntax is expected to be written by hand in a YAML file. We therefore
provide some convenient shorthands (listed above) to make YAML syntax files
more readable. These shorthands must be expanded to their full form before we
can apply the syntax to a file. There are two sets of shorthands we need to
expand:

* [[Scanner pattern shorthands|named_chunk_with_containers]]

* [[Scanner state shorthands|named_chunk_with_containers]]

The above code modifies the syntax object in place. This is safe because we are
working on a `deep_clone` of the original syntax:

[[lib/codnar/hash_extensions.rb|named_chunk_with_containers]]

#### Classifying Source Lines ####

Scanning a file to classified lines is a simple matter of applying the current
state transitions to each line:

[[Scanner file processing|named_chunk_with_containers]]

If a line matches a state transition, it is classified accordingly. Otherwise,
it is reported as an error:

[[Scanner line processing|named_chunk_with_containers]]

### Merging scanned lines to chunks ###

Once we have the array of scanned classified lines, we need to merge them into
nested chunks. Here is a simple test that demonstrates using the merger:

[[test/merge_lines.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/merger.rb|named_chunk_with_containers]]

#### Merging nested chunk lines ####

To merge the nested chunk lines, we maintain a stack of the current chunks.
Each `begin_chunk` line pushes another chunk on the stack, and each `end_chunk`
line pops it. If any chunks are not properly terminated, they will remain in
the stack when all the lines are processed.

[[Merging nested chunk lines|named_chunk_with_containers]]

#### Unindenting merged chunk lines ####

Nested chunks are typically indented relative to their container chunks.
However, in the generated documentation, these chunks are displayed on their
own, and preserving this relative indentation would reduce their readability.
We therefore unindent all chunks as much as possible as the final step.

[[Unindenting chunk lines|named_chunk_with_containers]]

### Generating chunk HTML ###

Now that we have each chunk's lines, we need to convert them to HTML.

#### Grouping lines of the same kind ####

Instead of formatting each line on its own, we batch the operations to work on
all lines of the same kind at once. Here is a simple test that demonstrates
using the grouper:

[[test/group_lines.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/grouper.rb|named_chunk_with_containers]]

#### Formatting lines as HTML ####

Formatting is based on a configuration that specifies, for (a group of) lines
of each kind, how to convert it to HTML. Here is a simple test that
demonstrates using the formatter:

[[test/format_lines.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/formatter.rb|named_chunk_with_containers]]

#### Basic formatters ####

The implementation contains some basic formatting functions. These are
sufficient for generic source code processing.

[[Basic formatters|named_chunk_with_containers]]

#### Markup formats ####

The `markup_lines_to_html` formatter above relies on the existence of a class
for converting comments from the specific markup format to HTML. Currently, two
such formats are supported:

* RDoc, the default markup format used in Ruby comments. Here is a simple test
  that demonstrates using RDoc:

  [[test/expand_rdoc.rb|named_chunk_with_containers]]

  And here is the implementation:

  [[lib/codnar/rdoc.rb|named_chunk_with_containers]]

* Markdown, a generic markup syntax used across many systems and languages.
  Here is a simple test that demonstrates using Markdown:

  [[test/expand_markdown.rb|named_chunk_with_containers]]

  And here is the implementation:

  [[lib/codnar/markdown.rb|named_chunk_with_containers]]

In both cases, the HTML generated by the markup format conversion is a bit
messy. We therefore clean it up:

[[Clean html|named_chunk_with_containers]]

#### Syntax highlighting using GVIM ####

If you have `gvim` istalled, it is possible to use it to generate syntax
highlighting. This is a *slow* operation, as `gvim` was never meant to be used
as a command-line tool. However, what it lacks in speed it compensates for in
scope; almost any language you can think of has a `gvim` syntax highlighting
definition. Here is a simple test that demonstrates using `gvim` for syntax
highlighting:

[[test/gvim_highlight_syntax.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/gvim.rb|named_chunk_with_containers]]

#### Syntax highlighting using Sunlight ####

[Sunlight](http://sunlightjs.com/) offers a different approach for syntax
highlighting. Instead of pre-processing the code to generate highlighted HTML
while splitting, it provides Javascript files that examine the textual code in
the DOM and convert it to highlighted HTML in the browser. This takes virtually
no time when splitting the code, but requires recomputing highlighting for all
the code chunks every time the HTML file is loaded. This can be pretty slow,
especially if using a browser with a slow Javascript engine, like IE. However,
given how slow GVIM is, this is a reasonable trade-off, at least for small
projects. Since Sunlight is a new project, it doesn't offer the extensive
coverage of different programming languages supported by GVIM.

Here is a simple test that demonstrates using Sunlight for syntax highlighting:

[[test/sunlight_highlight_syntax.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/sunlight.rb|named_chunk_with_containers]]

### Putting it all together ###

Now that we have all the separate pieces of functionality for splitting source
files into HTML chunks, we need to combine them to a single convenient service.

#### Splitting code files ####

Here is a simple test that demonstrates using the splitter for source code
files:

[[test/split_code.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/splitter.rb|named_chunk_with_containers]]

#### Splitting documentation files ####

The narrative documentation is expected to reside in one or more files, which
are also "split" to a single chunk each. Having both documentation and code
exist as chunks allows for uniform treatment of both when weaving, as well as
allowing for pre-processing the documentation files, if necessary. For example,
Codnar currently supports for documentation the same two markup formats that
are also supported for code comments. Here is a simple test that demonstrates
"splitting" documentation (using the same implementation as above):

[[test/split_documentation.rb|named_chunk_with_containers]]

### Built-in configurations ###

The splitting mechanism defined above is pretty generic. To apply it to a
specific system requires providing the appropriate configuration. The system
provides a few specific built-in configurations which may be useful "out of the
box".

If one is willing to give up altogether on syntax highlighting and comment
formatting, the system would be applicable as-is to any programming language.
Properly highlighting almost any known programming language syntax would be a
simple matter of passing the correct syntax parameter to GVIM.

Properly formatting comments in additional mark-up formats would be trickier.
First, a proper pattern needs to be established for extracting the comments
(`/*`, `//`, `--`, etc.). Them, the results need to be converted to HTML. One
way would be to pass them through GVim syntax highlighting with an appropriate
format (e.g, `syntax=doxygen`). Another would be to invoke some Ruby library;
finally, one could invoke some external tool to do the job. The latter two
options would require providing additional glue Ruby code, similar to the GVim
class above.

At any rate, here are the built-in configurations:

[[lib/codnar/split_configurations.rb|named_chunk_with_containers]]

#### Combining configurations ####

Different source files require different overall configurations but reuse
common building blocks. To support it, we allow comfigurations to be combined
using a "deep merge". This allows complex nested structures to be merged. There
is even a way for arrays to append elements before/after the array they are
merged with. Here is a simple test that demonstrates deep-merging complex
structures:

[[test/deep_merge.rb|named_chunk_with_containers]]

Here is the implementation:

[[Deep merge|named_chunk_with_containers]]

And here is a test module that automates the process of merging configurations
and invoking the Splitter:

[[test/lib/test_with_configurations.rb|named_chunk_with_containers]]

#### Documentation "splitting" ####

These are pretty simple configurations, applicable to files containing a piece
of the narrative in some supported format. These configurations typically do
not require to be combined with other configurations. Here is a simple test
that demonstrates "splitting" documentation:

[[test/split_documentation_configurations.rb|named_chunk_with_containers]]

And here are the actual configurations:

[[Documentation "splitting" configurations|named_chunk_with_containers]]

#### Source code lines classification ####

Splitting source code files is a more complex affair, which does typically
require combining several configurations. The basic configuration marks all
lines as belonging to some code syntax, as a single chunk:

[[Source code lines classification configurations|named_chunk_with_containers]]

Sometimes, a code in one syntax contains nested "islands" of code in another
syntax. Here is a simple configuration to support that, which can be combined
with the above basic configuration:

[[Nested foreign syntax code islands configurations|named_chunk_with_containers]]

Here is a simple test demonstrating using source code lines classifications:

[[test/split_code_configurations.rb|named_chunk_with_containers]]

#### Simple comment classification ####

Many languages use a simple comment syntax, where some prefix indicates a
comment that spans until the end of the line (e.g., shell `#` comments or C++
`//` comments).

[[Simple comment classification configurations|named_chunk_with_containers]]

Here is a simple test demonstrating using simple comment classifications:

[[test/split_simple_comment_configurations.rb|named_chunk_with_containers]]

#### Complex comment classification ####

Other languages use a complex multi-line comment syntax, where some prefix
indicates the beginning of the comment, some suffix indicates the end, and by
convention some prefix is expected for the inner comment lines (e.g., C's
"`/*`", "` *`", "`*/`" comments or HTML's "`<!--`", "` -`", "`-->`" comments).

[[Complex comment classification configurations|named_chunk_with_containers]]

Here is a simple test demonstrating using complex comment classifications:

[[test/split_complex_comment_configurations.rb|named_chunk_with_containers]]

#### Comment formatting ####

In many cases, the text inside comments is written using some markup format
(e.g., RDoc for Ruby or JavaDoc for Java). Currently, two such formats are
supported, as well as simply wrapping the comment in an HTML pre element:

[[Comment formatting configurations|named_chunk_with_containers]]

Here is a simple test demonstrating formatting comment contents:

[[test/format_comment_configurations.rb|named_chunk_with_containers]]

#### Syntax highlighting using GVim ####

Supporting a specific programming language (other than dealing with comments)
is very easy using GVim for syntax highlighting, as demonstrated here:

[[GVim syntax highlighting formatting configurations|named_chunk_with_containers]]

Here is a simple test demonstrating highlighting code syntax using `gvim`:

[[test/format_code_gvim_configurations.rb|named_chunk_with_containers]]

#### Syntax highlighting using Sunlight ####

For small projects in languages supported by Sunlight, you may choose to use
it instead of GVIM

[[Sunlight syntax highlighting formatting configurations|named_chunk_with_containers]]

Here is a simple test demonstrating highlighting code syntax using Sunlight:

[[test/format_code_sunlight_configurations.rb|named_chunk_with_containers]]

#### Chunk splitting ####

There are many ways to denote code "regions" (which become Codnar chunks). The
following covers GVim's default scheme; others are easily added. It is safest
to merge this configuration as the last of all the combined configurations, to
ensure its patterns end up before any others.

[[Chunk splitting configurations|named_chunk_with_containers]]

Here is a simple test demonstrating splitting code chunks:

[[test/split_chunk_configurations.rb|named_chunk_with_containers]]

### Putting it all together ###

Here is a test demonstrating putting several of the above configurations
together in a meaningful way:

[[test/split_combined_configurations.rb|named_chunk_with_containers]]

## Storing chunks on the disk ##

### Writing chunks to disk ###

In any realistic system, the number of source files and chunks will be such
that it makes sense to store the chunks on the disk for further processing.
This allows incorporating the split operation as part of a build tool chain,
and only re-splitting modified files. Here is a simple test demonstrating
writing chunks to the disk:

[[test/write_chunks.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/writer.rb|named_chunk_with_containers]]

### Reading chunks to memory ###

Having written the chunks to the disk requires us, at some following point in
time, to read them back into memort. This is the first time we will have a view
of the whole documented system, which allows us to detect several classes of
consistency errors: Some chunks may be left out of the final narrative
(consider this the equivalent of tests code coverage); we may be referring to
missing (or misspelled) chunk names; and, finally, we need to deal with
duplicate chunks.

In literate programming, it is trivial to write a chunk once and use it in
several places in the compiled source code. The classical example is C/C++
function signatures that need to appear in both the `.h` and `.c`/`.cpp` files.
However, in some cases this practice makes sense for other pieces of code, and
since the ultimate source code contains only one copy of the chunk, this does
not suffer from the typical copy-and-paste issues.

In inverse literate programming, if the same code appears twice (as a result of
copy-and-paste), then it does suffer from the typical copy-and-paste issues.
The most serious of these is, of course, that when only one copy is changed.
The way that Codnar helps alleviate this problem is that if the same chunk
appears more than once in the source code, its content is expected to be
exactly the same in both cases (up to indentation). This should not be viewed
as endorsement of copy-and-paste programming; Using duplicate chunks should be
a last resort measure to combat restrictions in the programming language and
compilation tool chain.

#### Chunk identifiers ####

The above definition raises the obvious question: what does "the same chunk"
mean? As far as Codnar is concerned, a chunk is uniquely identified by its
name, which is specified on the `begin_chunk` line. The unique identifier is
not the literal name but a transformation of it. This allows us to ignore
capitalization, white space, and any punctuation that may appear in the name.
It also allows us to use the resulting ID as an HTML anchor name, without
worrying about HTML's restictions on such names.

Here is a simple test demonstrating converting names to identifiers:

[[test/identify_chunks.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/string_extensions.rb|named_chunk_with_containers]]

#### In-memory chunks storage ####

Detecting unused and/or duplicate chunks requires us to have in-memory chunk
storage that tracks all chunks access. Here is a simple test demonstrating
reading chunks into the storage and handling the various error conditions
listed above:

[[test/read_chunks.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/reader.rb|named_chunk_with_containers]]

## Weaving chunks into HTML ##

Assembling the final HTML requires combining both the narrative documentation
and source code chunks. This is done top-down starting at a "root"
documentation chunk and recursively embedding nested documentation and code
chunks into it.

### Weaving chunks together ###

When embedding a documentation chunk inside another documentation chunk, things
are pretty easy - we just need to insert the embedded chunk HTML into the
containing chunk. When embedding a source code chunk into the documentation,
however, we may want to wrap it in some boilerplate HTML, providing a header,
footer, borders, links, etc. Therefore, the HTML syntax we use to embed a chunk
into the documentation is `<embed src="..." type="x-codnar/template-name"/>`.
The templates are normal ERB templates, except for the magical `file` and
`image` templates, described below.

At any rate, here is a simple test demonstrating applying different templates
to the embedded code chunks:

[[test/weave_configurations.rb|named_chunk_with_containers]]

Here is the implementation:

[[lib/codnar/weaver.rb|named_chunk_with_containers]]

And here are the pre-defined weaving template configurations:

[[lib/codnar/weave_configurations.rb|named_chunk_with_containers]]

#### Embedding files ####

The template named `file` is special in two ways. First, the `src` is given
special treatment. If it begins with a "`.`", it is assumed to be a normal path
name relative to the current working directory; otherwise, it is assumed to be
a name of a file packaged inside some gem and is searched for in Ruby's
`$LOAD_PATH`. This allows gems (such as Codnar itself) to provide such files to
be used in the woven documentation.

Second, the content of the file is simply embedded into the generated
documentation. This allows the documentation to be a stand-alone file,
including all the CSS and Javascript required for proper display.

[[Processing the file template|named_chunk_with_containers]]

See the `doc/root.html` file for plenty of examples of using this
functionality.

#### Embedding images ####

The `image` template is a specialization of the `file` template for dealing
with embedded images. The specified image file is embedded into the generated
HTML as an `img` tag, using a [data
URL](http://en.wikipedia.org/wiki/Data_URI_scheme). This is very useful for
small images, but is problematic when their size increase beyond
browser-specific limits.

Here is a simple test demonstrating processing embedded image files:

[[test/embed_images.rb|named_chunk_with_containers]]

Here is the implementation:

[[Processing Base64 embedded data images|named_chunk_with_containers]]

And here is a sample embedded image:

[[doc/logo.png|image]]

## Invoking the functionality ##

There are two ways to invoke Codnar's functionality - from the command line,
and (for Ruby projects) as integrated Rake tasks.

### Command Line Applications ###

Executable scripts (tests, command-line applications) start with a `require
'codnar'` line to access to the full Codnar code. This also serves as a
convenient list of all of Codnar's parts and dependencies:

[[lib/codnar.rb|named_chunk_with_containers]]

The base command line Application class handles execution from the command
line, with the usual standard options, as well as some Codnar-specific ones:
the ability to specify configuration files and/or built-in configurations, and
the ability to include additional extension code triggered from these
configurations. Together, these allow configuring and extending Codnar's
behavior to cover the specific system's needs.

Here is a simple test demonstrating the standard Codnar application behavior:

[[test/run_application.rb|named_chunk_with_containers]]

And here is the implementation:

[[lib/codnar/application.rb|named_chunk_with_containers]]

#### Application for splitting files ####

Here is a simple test demonstrating invoking the command-line application for
splitting files:

[[test/run_split.rb|named_chunk_with_containers]]

Here is the implementation:

[[lib/codnar/split.rb|named_chunk_with_containers]]

And here is the actual command-line application script:

[[bin/codnar-split|named_chunk_with_containers]]

#### Application for weaving chunks ####

Here is a simple test demonstrating invoking the command-line application for
weaving chunk to HTML:

[[test/run_weave.rb|named_chunk_with_containers]]

Here is the implementation:

[[lib/codnar/weave.rb|named_chunk_with_containers]]

And here is the actual command-line application script:

[[bin/codnar-weave|named_chunk_with_containers]]

### Rake Integration ###

For Ruby projects (or any other project using Rake), it is also possible to
invoke Codnar using Rake tasks. Here is a simple test demonstrating using the
Rake tasks:

[[test/rake_tasks.rb|named_chunk_with_containers]]

To use these tasks in a Rakefile, one needs to `require 'codnar/rake'`. The
code implements a singleton that holds the global state shared between tasks:

[[lib/codnar/rake.rb|named_chunk_with_containers]]

#### Task for splitting files ####

To split one or more files to chunks, create a new SplitTask. Multiple such
tasks may be created; this is required if different files need to be split
using different configurations.

[[lib/codnar/rake/split_task.rb|named_chunk_with_containers]]

#### Task for weaving chunks ####

To weave the chunks together, create a single WeaveTask.

[[lib/codnar/rake/weave_task.rb|named_chunk_with_containers]]

## Building the Codnar gem ##

The following Rakefile is in charge of building the gem, with the help of some
tools described below.

[[Rakefile|named_chunk_with_containers]]

The generated HTML requires some tweaking to yield aesthetic, readable results.
This tweaking consists of using Javascript to control chunk visibility,
generating a table of content, and using CSS to make the HTML look better.

Here are the modified configurations for generating the correct HTML:

[[Codnar configurations|named_chunk_with_containers]]

### Javascript chunk visibilty control ###

The following code injects visibility controls ("+"/"-" toggles) next to each
embedded code chunk. It also hides all the chunks by default; this increases
the readability of the overall narrative, turning it into a high-level summary.
Expanding the embedded code chunks allows the reader to delve into the details.

[[lib/codnar/data/control_chunks.js|named_chunk_with_containers]]

### Javascript table of content ###

The following code is not very efficient or elegant but it does a basic job of
iunjecting a table of content into the generated HTML.

[[lib/codnar/data/contents.js|named_chunk_with_containers]]

### CSS style ###

To avoid dealing with the different default styles used by different browsers,
we employ the YUI CSS [reset](http://developer.yahoo.com/yui/reset/) and
[base](http://developer.yahoo.com/yui/base/) files. Resetting and restoring the
default CSS styles is inelegant, but it is the only current way to get a
consistent presentation of HTML. Once this is out of the way, we apply styles
specific to our HTML. Some of these override the default styles established by
the base CSS file above. We do this instead of directly tweaking the base CSS
file, to allow easy upgrade to new versions if/when YUI release any.

[[lib/codnar/data/style.css|named_chunk_with_containers]]

### Using Sunlight ###

When using Sunlight for syntax highlighting, we also need to include some CSS
and Javascript files to convert the classified `pre` elements into properly
marked-up HTML. We also need to invoke this Javascript code (a one-line
operations). See the last few lines of the `doc/root.html` file for details.
