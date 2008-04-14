require 'rake'
require 'lib/pdoc'

desc "Builds the documentation"
task :build_doc do
  source = File.expand_path(File.join(File.dirname(__FILE__), "test", "fixtures", "ajax.js"))
  PDoc::Runner.new(source).run
end

desc "Empties output directory"
task :remove_doc do
  rm_rf Dir.glob(File.join(OUTPUT_DIR, "*"))
end

desc "Empties the output directory and builds the documentation."
task :doc => [:remove_doc, :build_doc]

desc "Runs all the unit tests."
task :test do 
  require 'rake/runtest'
  Rake.run_tests '**/*_test.rb'
end

task :compile_parser do
  require 'treetop'
  compiler = Treetop::Compiler::GrammarCompiler.new
  treetop_dir = File.expand_path(File.join(File.dirname(__FILE__), "lib", "pdoc", "parser", "treetop_files"))
  Dir.glob(File.join(treetop_dir, "*.treetop")).each do |treetop_file_path|
    compiler.compile(treetop_file_path)
  end
end
