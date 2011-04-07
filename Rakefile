$: << File.dirname(__FILE__) + "/lib"

require "codnar/rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "rcov/rcovtask"
require "reek/rake/task"
require "roodi"
require "roodi_task"

# Overall tasks

task :default => :all

desc "Verify, document, package"
task :all => [ :verify, :doc, :gem ]

desc "Generate all documentation"
task :doc => [ :rdoc, :codnar ]

desc "Test, coverage, analyze code"
task :verify => [ :rcov, :reek, :roodi, :flay, :saikuro ]

# Source file lists

patterns = {
  "bin" => "bin/*",
  "css" => "doc/*.css",
  "doc" => "doc/*",
  "javascript" => "doc/*.js",
  "lib" => "lib/**/*.rb",
  "test" => "test/*.rb",
  "testlib" => "test/lib/*.rb",
  "tools" => "tools/*",
}
files = patterns.merge(patterns) { |key, pattern| FileList[pattern] }


# Gem specification and packaging

spec = Gem::Specification.new do |s|

  s.name = "codnar"
  s.version = Codnar::VERSION

  s.homepage = "http://codnar.rubygems.org"

  s.summary = "Code narrator - an inverse literate programming tool."
  s.description = (<<-EOF).gsub(/^\s+/, "").chomp.gsub("\n", " ")
    Code Narrator (Codnar) is an inverse literate programming tool. It splits the
    source files into "chunks" (including structured comments) and weaves them back
    into a narrative that describes the overall system.
  EOF

  s.author = "Oren Ben-Kiki"
  s.email = "rubygems-oren@ben-kiki.org"

  s.requirements << "GVim for syntax highlighting."

  s.add_dependency("andand")
  s.add_dependency("getoptions")
  s.add_dependency("rake")
  s.add_dependency("rdiscount")
  s.add_dependency("rdoc")

  s.add_development_dependency("fakefs")
  s.add_development_dependency("flay")
  s.add_development_dependency("rcov")
  s.add_development_dependency("reek")
  s.add_development_dependency("roodi")
  s.add_development_dependency("Saikuro")
  s.add_development_dependency("test-spec")

  s.files = files.lib + files.bin + files.doc
  s.test_files = files.test + files.testlib
  s.executables = files.bin.map { |path| path.sub("bin/", "") }

  s.extra_rdoc_files = [ "README.rdoc", "LICENSE", "ChangeLog" ]
  s.rdoc_options << "--title" << "Code narrator #{s.version}"
  s.rdoc_options << "--main" << "README.rdoc"
  s.rdoc_options << "--line-numbers"
  s.rdoc_options << "--all"
  s.rdoc_options << "--quiet"

end

Rake::GemPackageTask.new(spec) { |package| }

# Unit tests

Rcov::RcovTask.new("rcov") do |task|
  task.output_dir = "rcov"
  task.test_files = files.test
  task.libs << "lib" << "test/lib"
  task.rcov_opts << "--failure-threshold" << "100"
  (files.lib + files.test + files.testlib).each do |file|
    task.rcov_opts << "--include-file" << file
  end
end

# Code analysis

Reek::Rake::Task.new do |task|
  task.reek_opts << "--quiet"
  task.source_files = files.lib + files.bin + files.test + files.testlib
end

RoodiTask.new do |task|
  task.patterns = patterns.values
  task.config = "roodi.config"
end

Rake::TestTask.new("test") do |task|
  task.test_files = files.test
  task.libs << "lib" << "test/lib"
end

desc "Check for duplicated code with Flay"
task :flay do
  result = IO.popen("flay lib", "r").read.chomp
  unless result == "Total score (lower is better) = 0\n"
    print result
    raise "Flay found code duplication."
  end
end

CLOBBER << "saikuro"

desc "Check for complex code with Saikuro"
task :saikuro do
  system("saikuro -c -t -i lib -y 0 -e 10 -o saikuro/ > /dev/null")
  result = File.read("saikuro/index_cyclo.html")
  if result.include?("Errors and Warnings")
    raise "Saikuro found complicated code."
  end
end

# Documentation

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files << "LICENSE" << "README.rdoc"
  rdoc.rdoc_files += files.bin + files.lib + files.test + files.testlib
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "rdoc"
  rdoc.options = spec.rdoc_options
end

def syntax_configurations(syntax)
  return [
    "classify_source_code:#{syntax}",
    "css_code_syntax:#{syntax}",
    "classify_simple_comments:#",
    "format_rdoc_comments",
    "css_code_syntax:html",
    "nested_code_syntax:ruby:html"
  ]
end

Codnar::Rake::SplitTask.new(files.bin + files.lib + files.testlib + [ "Rakefile", "tools/codnar-changelog" ],
                            syntax_configurations("ruby") + [ "chunk_by_vim_regions" ])
Codnar::Rake::SplitTask.new(files.javascript, syntax_configurations("javascript"))
Codnar::Rake::SplitTask.new(files.css, syntax_configurations("css"))
Codnar::Rake::SplitTask.new(files.test + files.tools - [ "tools/codnar-changelog" ], syntax_configurations("ruby"))
Codnar::Rake::SplitTask.new(spec.files.find_all { |file| file.end_with?(".html") }, [ :split_html_documentation ])
Codnar::Rake::SplitTask.new(spec.files.find_all { |file| file.end_with?(".rdoc") }, [ :split_rdoc_documentation ])
Codnar::Rake::SplitTask.new(spec.files.find_all { |file| file.end_with?(".markdown") }, [ :split_markdown_documentation ])
Codnar::Rake::WeaveTask.new("doc/root.html", [ :weave_include, :weave_named_chunk_with_containers ])
