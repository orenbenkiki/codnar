$LOAD_PATH.unshift(File.dirname(__FILE__) + "/lib")

require "olag/rake"

# {{{ Codnar configurations

# Override the default Codnar configurations.
Olag::Rake::CODNAR_CONFIGURATIONS.unshift([
  # Exclude the data files and images from the generated documentation.
  "lib/codnar/data/.*/.*|.*\.png",
], [
  # Tests should not have chunks detected in them.
  # They may however contain HTML islands.
  "test/.*\.rb",
  "classify_source_code:ruby",
  "format_code_sunlight:ruby",
  "classify_nested_code:ruby:html",
  "format_code_sunlight:html",
  "classify_shell_comments",
  "format_rdoc_comments",
], [
  # Ruby sources contain HTML islands.
  "Rakefile|.*\.rb|bin/.*",
  "classify_source_code:ruby",
  "format_code_sunlight:ruby",
  "classify_nested_code:ruby:html",
  "format_code_sunlight:html",
  "classify_shell_comments",
  "format_rdoc_comments",
  "chunk_by_vim_regions",
], [
  # We also have Javascript sources.
  ".*\.js",
  "classify_source_code:javascript",
  "format_code_sunlight:javascript",
  "classify_c_comments",
  "format_markdown_comments"
], [
  # We also have CSS sources.
  ".*\.css",
  "classify_source_code:css",
  "format_code_sunlight:css",
  "classify_c_comments",
  "format_markdown_comments"
])

# }}}

spec = Gem::Specification.new do |spec|
  spec.name = "codnar"
  spec.version = Codnar.version
  spec.title = "Code Narrator"
  spec.author = "Oren Ben-Kiki"
  spec.email = "rubygems-oren@ben-kiki.org"
  spec.homepage = "http://codnar.rubygems.org"
  spec.summary = "Code narrator - an inverse literate programming tool."
  spec.description = (<<-EOF).gsub(/^\s+/, "").chomp.gsub("\n", " ")
    Code Narrator (Codnar) is an inverse literate programming tool. It splits the
    source files into "chunks" (including structured comments) and weaves them back
    into a narrative that describes the overall system.
  EOF
  spec.add_dependency("andand")
end

Olag::Rake.new(spec)
