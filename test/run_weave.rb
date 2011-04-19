require "codnar"
require "olag/test"
require "test/spec"

# Test running the Weave Codnar Application.
class TestRunWeave < Test::Unit::TestCase

  include Test::WithFakeFS

  def test_print_help
    Codnar::Application.with_argv(%w(-o stdout -h)) { Codnar::Weave.new(true).run }.should == 0
    help = File.read("stdout")
    [ "codnar-weave", "OPTIONS", "DESCRIPTION" ].each { |text| help.should.include?(text) }
  end

  ROOT_CHUNKS = [ {
    "name" => "root",
    "locations" => [ { "file" => "root", "line" => 1 } ],
    "html" => "Root\n<embed src='included' type='x-codnar/include'/>\n"
  } ]

  INCLUDED_CHUNKS = [ {
    "name" => "included",
    "locations" => [ { "file" => "included", "line" => 1 } ],
    "html" => "Included"
  } ]

  def test_run_weave
    File.open("root", "w") { |file| file.write(ROOT_CHUNKS.to_yaml) }
    File.open("included", "w") { |file| file.write(INCLUDED_CHUNKS.to_yaml) }
    Codnar::Application.with_argv(%w(-o stdout root included)) { Codnar::Weave.new(true).run }.should == 0
    File.read("stdout").should == "Root\nIncluded\n"
  end

  def test_run_weave_missing_chunk
    File.open("root", "w") { |file| file.write(ROOT_CHUNKS.to_yaml) }
    Codnar::Application.with_argv(%w(-e stderr -o stdout root)) { Codnar::Weave.new(true).run }.should == 1
    File.read("stderr").should == "#{$0}: Missing chunk: included in file: root\n"
  end

  def test_run_weave_unused_chunk
    File.open("root", "w") { |file| file.write(ROOT_CHUNKS.to_yaml) }
    File.open("included", "w") { |file| file.write(INCLUDED_CHUNKS.to_yaml) }
    Codnar::Application.with_argv(%w(-e stderr -o stdout included root)) { Codnar::Weave.new(true).run }.should == 1
    File.read("stderr").should == "#{$0}: Unused chunk: root in file: root at line: 1\n"
  end

  def test_run_weave_no_chunks
    Codnar::Application.with_argv(%w(-e stderr)) { Codnar::Weave.new(true).run }.should == 1
    File.read("stderr").should == "#{$0}: No chunk files to weave\n"
  end

  FILE_CHUNKS = [ {
    "name" => "root",
    "locations" => [ { "file" => "root", "line" => 1 } ],
    "html" => "Root\n<embed src='included.file' type='x-codnar/file'/>\n"
  } ]

  def test_run_weave_missing_file
    File.open("root", "w") { |file| file.write(FILE_CHUNKS.to_yaml) }
    Codnar::Application.with_argv(%w(-e stderr -o stdout root)) { Codnar::Weave.new(true).run }.should == 1
    double_message = "No such file or directory - " * 2 # Something weird in Ruby Exception.to_s
    File.read("stdout").should == "Root\nFILE: included.file EXCEPTION: #{double_message}\n"
    File.read("stderr").should \
      == "#{$0}: Reading file: included.file exception: #{double_message} in file: root at line: 1\n"
  end

  def test_run_weave_existing_file
    File.open("root", "w") { |file| file.write(FILE_CHUNKS.to_yaml) }
    File.open("included.file", "w") { |file| file.write("included file\n") }
    Codnar::Application.with_argv(%w(-e stderr -o stdout root)) { Codnar::Weave.new(true).run }.should == 0
    File.read("stdout").should == "Root\nincluded file\n"
  end

end
