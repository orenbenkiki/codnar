require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "rcov/rcovtask"
require "reek/rake/task"
require "roodi"
require "roodi_task"
require "lib/codnar/version"

task :default => "all"
task "all" => [ "verify", "rdoc", "gem" ]
task "verify" => [ "rcov", "reek", "roodi" ]

patterns = { "bin" => "bin/*", "lib" => "lib/**/*.rb", "test" => "test/**/*.rb" }
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

  s.requirements << "GVim for syntax highlighting, Pod2Html for processing POD documentation (only if these are used in your documentation)."

  s.add_dependency("getoptions")
  s.add_dependency("rdiscount")

  s.add_development_dependency("rake")
  s.add_development_dependency("rcov")
  s.add_development_dependency("reek")
  s.add_development_dependency("roodi")
  s.add_development_dependency("test-spec")

  s.files = files["lib"] + files["bin"]
  s.test_files = files["test"]
  s.executables = files["bin"].map { |path| path.sub("bin/", "") }
  s.default_executable = "bin/codnar"

  s.has_rdoc = true
  s.extra_rdoc_files = [ "README.rdoc", "LICENSE", "ChangeLog" ]
  s.rdoc_options << "--title" << "Code narrator #{s.version}"
  s.rdoc_options << "--main" << "README.rdoc"
  s.rdoc_options << "--line-numbers"

end

Rake::GemPackageTask.new(spec) { |package| }

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add("LICENSE")
  rdoc.rdoc_files.add("README.rdoc")
  rdoc.rdoc_files.add(files["bin"])
  rdoc.rdoc_files.add(files["lib"])
  rdoc.rdoc_files.add(files["test"])
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "rdoc"
  rdoc.options = spec.rdoc_options
end

Reek::Rake::Task.new do |task|
  task.reek_opts = "--quiet"
  task.source_files = files.values.flatten
end

RoodiTask.new do |task|
  task.patterns = patterns.values
end

CLEAN.include("SANDBOX*")

Rake::TestTask.new("test") do |task|
  task.test_files = files["test"]
  task.libs << "lib"
  task.verbose = false
end

Rcov::RcovTask.new("rcov") do |task|
  task.output_dir = "rcov"
  task.test_files = files["test"]
  task.libs << "lib"
  task.verbose = false
  task.rcov_opts << "--text-summary"
  task.rcov_opts << "--text-summary"
  task.rcov_opts << "--failure-threshold" << "100"
  (files["lib"] + files["test"]).each do |file|
    task.rcov_opts << "--include-file" << file \
      unless file == "lib/codnar/test/failure.rb" # TRICKY: Test failure code should not be reached.
  end
end