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

task :default => :all

desc "Verify, document, package"
task :all => [ :verify, :doc, :gem ]

desc "Generate all documentation"
task :doc => [ :rdoc, :codnar ]

desc "Test, coverage, analyze code"
task :verify => [ :rcov, :reek, :roodi, :flay, :saikuro ]

patterns = {
  "bin" => "bin/*",
  "lib" => "lib/**/*.rb",
  "doc" => "doc/*",
  "test" => "test/*.rb",
  "testlib" => "test/lib/*.rb"
}
files = patterns.merge(patterns) { |key, pattern| FileList[pattern] }

spec = Gem::Specification.new do |s|

  s.name = "codenar"
  s.version = Codnar::VERSION

  s.homepage = "http://codenar.rubygems.org"

  s.summary = "Code narrator - a reverse literate programming tool."
  s.description = (<<-EOF).gsub(/^\s+/, "").chomp.gsub("\n", " ")
    Code narrator is a reverse literate programming tool. It splits the source
    files into "chunks" (including structured comments) and weaves them back
    into a narrative that describes the overall system.
  EOF

  s.author = "Oren Ben-Kiki"
  s.email = "oren@ben-kiki.org"

  s.requirements << "GVim for syntax highlighting."

  s.add_dependency("andand")
  s.add_dependency("erb")
  s.add_dependency("getoptions")
  s.add_dependency("rake")
  s.add_dependency("rdiscount")
  s.add_dependency("rdoc")

  s.add_development_dependency("flay")
  s.add_development_dependency("rcov")
  s.add_development_dependency("reek")
  s.add_development_dependency("roodi")
  s.add_development_dependency("saikuro")
  s.add_development_dependency("test-spec")

  s.files = files["lib"] + files["bin"] + files["doc"]
  s.test_files = files["test"] + files["testlib"]
  s.executables = files["bin"].map { |path| path.sub("bin/", "") }

  s.has_rdoc = true
  s.extra_rdoc_files = [ "README.rdoc", "LICENSE", "ChangeLog" ]
  s.rdoc_options << "--title" << "Code narrator #{s.version}"
  s.rdoc_options << "--main" << "README.rdoc"
  s.rdoc_options << "--line-numbers"
  s.rdoc_options << "--all"
  s.rdoc_options << "--quiet"

end

Rake::GemPackageTask.new(spec) { |package| }

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add("LICENSE")
  rdoc.rdoc_files.add("README.rdoc")
  rdoc.rdoc_files.add(files["bin"])
  rdoc.rdoc_files.add(files["lib"])
  rdoc.rdoc_files.add(files["test"])
  rdoc.rdoc_files.add(files["testlib"])
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "rdoc"
  rdoc.options = spec.rdoc_options
end

Reek::Rake::Task.new do |task|
  task.reek_opts = "--quiet"
  task.source_files = files["lib"] + files["bin"] + files["test"] + files["testlib"]
end

RoodiTask.new do |task|
  task.patterns = patterns.values
end

Rake::TestTask.new("test") do |task|
  task.test_files = files["test"]
  task.libs << "lib"
  task.libs << "test/lib"
end

Rcov::RcovTask.new("rcov") do |task|
  task.output_dir = "rcov"
  task.test_files = files["test"]
  task.libs << "lib"
  task.libs << "test/lib"
  task.rcov_opts << "--failure-threshold" << "100"
  (files["lib"] + files["test"] + files["testlib"]).each do |file|
    task.rcov_opts << "--include-file" << file
  end
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

Codnar::Rake::SplitTask.new(files["doc"], [])
Codnar::Rake::SplitTask.new([ "README.rdoc" ], [ :split_rdoc_documentation ])
Codnar::Rake::WeaveTask.new("doc/root.html", [])
