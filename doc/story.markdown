## The Story ##

This is the story of the Code Narrator (Codnar) tool. It serves a dual purpose.
It describes the Codnar tool itself, but it also serves as an example of why it
exists in the first place. To explain this more fully, we'll have to make a
little detour into the issue of system documentation.

### The Documentation Problem ###

Documentation for any system can be grouped to two kinds. The first kind is the
reference manual. If you know of a small piece of the system, this kind of
documentation will give you the details about it. A good reference will help
you find this piece even if you only have a rough idea of what it is named. A
really good reference will also link it to related pieces. A great reference
will even give you example of how to use the related pieces in a realistic
context.

Reference manuals are invaluable, and there are plenty of tools to help you
create them. The common approach is the use of structured comments (e.g.,
[JavaDoc](http://en.wikipedia.org/wiki/Javadoc),
[Doxygen](http://en.wikipedia.org/wiki/Doxygen), and a [host of similar
tools](http://en.wikipedia.org/wiki/Comparison_of_documentation_generators)).
However, reference manuals by themselves are insufficient.

A reference manual only works if you have some idea about how the system works
as a whole. For that, you need some sort of overview. Here there is much less
to help you produce good documentation. The common practice is to sprinkle
small tutorials inside your reference documentation (the [MSDN
library](http://msdn.microsoft.com/en-us/library) is a good example). This
doesn't really solve the problem: how do you sufficiently explain a complex new
system, so that references and small tutorials become useful?

One possible solution to this problem, [literate
programming](http://en.wikipedia.org/wiki/Literate_programming), was proposed
by Knuth. In a nutshell, the idea was that the source code for the system
fulfilled a dual role. You could compile it into the executable code, as
expected. But you could also generate documentation from it.

So far this sounds a lot like structured comments, and indeed structured
comments were inspired by literate programming. The key difference between the
two approaches is that in literate programming, the generated documentation was
not a reference manual. It was a linear narrative describing the system - a
story which walked you through the system in an specific path chosen for
optimal presentation.

To achieve this, the sources contained the linear documentation, with embedded
code "chunks". The order of the chunks in the sources was determined by the
narrative, not the programming language requirements. Extracting and
re-ordering these chunks was part of the build process, so the regular compiler
could process them as usual.

This was the great strength, but also the great weakness, of literate
programming. For example, it is next to impossible to create IDEs and similar
tools for literate programming source code. The code chunks are split any which
way and spread around the source files in any order; the same source file may
contain chunks in several languages; etc. Automatically figuring out, say, the
list of members of some class would be a daunting task.

In contrast, structured comments stay out of the way of the IDE and similar
tools. The source code is still structured exactly the way the compiler wants,
which allows for easy, localized processing. The trade-off, of course, is that
structured comments produce a reference manual, not a narrative.

Today, structured comments have taken over the coding world, and literate
programming has all but been forgotten. The problem it tried to solve, however,
is still very much with us. How do we explain a new complex system?

### A Different Approach ###

Codnar is an example of a different approach for solving this problem, "inverse
literate programming" (similar to, for example,
[antiweb](http://packages.python.org/antiweb/)). This approach is a combination
of structured comments and literate programming. Note that this approach is
similar to, but different in key aspects from, [reverse literate
programming](http://ssw.jku.at/Research/Projects/RevLitProg/).

In inverse literate programming, the source files are organized just
the way the compiler, IDE, and similar tools expect them to be. Structured
comments are used to document the pieces of code, and a reference manual can be
generated from the sources as usual.

In addition, the code is split into (possibly nested) named "chunks". This is
done using specially formatted comments. It turns out this functionality is
already supported by most coding editors and IDEs, in the form of "folds" or
"regions". These allow the developer to collapse or expand such chunks at will.

At this point, inverse literate programming kicks in. The developer writes
additional documentation source files, next to the usual code source files.
These documentation source files contain a narrative that describes the system,
much in the same way that a literate programming documentation would have done,
with two important differences.

The first difference is that the documentation source files refer to and embed
the code chunks (using their names), as opposed to a literate programming
system, where the documentation source files actually contain the code chunks.

The second difference is that the documentation source files do not need to
repeat the information that is already covered in the structured comments. When
a code chunk is embedded into the documentation, it includes these comments, so
all the documentation source files need to contain is the narrative "glue" for
placing these pieces into a comprehensible context for the reader.

In this way, inverse literate programming allows generating a linear narrative
describing the system, without abandoning the existing code processing tools.
It also makes it easy to retrofit such documentation to an existing code base;
all that's needed is to mark the already-documented code chunks (or even just
treat each source code file as a single chunk), and provide the narrative glue
around them.

### Maintaining the Documentation ###

Structutred comments have the advantage that they are easy to maintain. Every
time you change a piece of code, change its comment to match. Simiarlt,
literate programming forced one to maintain the documentation as well, since
the same source file was used for code and documentation. Inverse literate
programming does not share this advantage. The linear documentation is in a
separate file, so it isn't immediately visible to the developer who is making
the changes. Also, it is easy to just forget to include some chunks of code in
the documentation.

These issues are very similar to the issues of unit testing. Unit tests live in
a separate file from the code they test, and it is easy to forget to test some
chunks of code. One way to ensure all code is tested is to use a code coverage
tool. Similarly, inverse literate programming tools should complain about code
chunks that are left out of the final narrative.

A different approach,
[TDD](http://en.wikipedia.org/wiki/Test-driven_development), ensures that the
tests are up-to-date and complete by writing the tests before the code. The
same approach can be used for documentation.
[DDD](http://thinkingphp.org/spliceit/docs/0.1_alpha/pages/ddd_info.html) means
that you first document what you are about to do, and only then follow up with
the actual coding. Inverse literate programming and TDD are an excellent
practical way to achieve that.

The unit tests are code like any other code. As such, they should be documented
using structured comments. Certain unit test tools like
[RSpec](http://rspec.info/), [Cucumber](http://cukes.info/) and other
[BDD](http://en.wikipedia.org/wiki/Behavior_Driven_Development) tools blur the
line between the tests-as-code and the tests-as-documentation anyway, so the
amount of unit test structured documentation should be small.

Therefore, if you are writing the tests first, you have done the heavy lifting
of documenting what the new code will do. All that is left is providing a bit
of surrounding context and embedding it all in the currect location in the
narrative. Then, when you write the new code itself, it should be easy to
connect it to the narrative at the appropriate point.

In the case of Code Narrator itself, the number of (raw) lines in the code
library itself is ~2100 lines, the number of test code lines is ~2200 lines,
and the number of narrative documentation lines is only ~900 lines. Given
narrative documentation are easier to write than system (or test) code, this
indicates maintaining a narrative is not an unreasonable burden for a
well-tested project.

### Code Narrator ###

Codnar is an inverse literate programming tool. It allows you to tell a story
about your system, which will explain it to others: developers, maintainers,
and/or users. It builds on the structured comments you would write anyway to
generate a reference manual for the system, requires minimal or no changes to
your source code files, and works perfectly well inside your favorite IDE or
editor. If you follow TDD or BDD, Codnar will make it easier for you to
complement it with DDD.

The rest of this document goes into the details of Codnar's implementation. The
core of the system is the following simple data flow: A set of source files is
split into chunks; the chunks are woven into a single HTML. This simple flow
can be enhanced by pre-processing the sources, or post-processing the HTML. In
a realistic project, all this would be managed by some build tool; either using
the command-line (for arbitrary build tools) or using the provided Ruby classes
for Rake integration.
