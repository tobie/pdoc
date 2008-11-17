Gem::Specification.new do |s|
  s.name     = "pdoc"
  s.version  = "0.1.0"
  s.date     = "2008-11-17"
  s.summary  = "Inline comment parser and JavaScript documentation generator"
  s.email    = "tobie.langel@gmail.com"
  s.homepage = "http://pdoc.org/"
  s.description = "PDoc is an inline comment parser and JavaScript documentation generator written in Ruby. It is designed for documenting Prototype and Prototype-based libraries."
  s.has_rdoc = true
  s.authors  = ["Tobie Langel"]
  s.files    = [
        "CHANGELOG", 
		"README.markdown", 
		"Rakefile", 
		"pdoc.gemspec",
		
		"lib/pdoc.rb",
        "lib/pdoc/runner.rb"] +
        
        ["",
        "/html",
        "/html/bluecloth_extension",
        "/html/helpers",
        "/html/template",
        "/html/page",
        "/html/website"].map { |f| "lib/pdoc/generators#{f}.rb" } +
        
        ["/argument_description",
        "/basic",
        "/description",
        "/documentation",
        "/ebnf_arguments",
        "/ebnf_expression",
        "/ebnf_javascript",
        "/events",
        "/section_content",
        "/tags"].map { |f| "lib/pdoc/parser/treetop_files#{f}.treetop" } +
        
        ["",
        "/basic_nodes",
        "/tags_nodes",
        "/argument_description_nodes",
        "/description_nodes",
        "/ebnf_arguments_nodes",
        "/ebnf_expression_nodes",
        "/section_content_nodes",
        "/documentation_nodes"].map { |f| "lib/pdoc/parser#{f}.rb" } +
        
        Dir['templates/**/*']
  
  s.autorequire = "lib/pdoc.rb"
  
  s.bindir = "bin"
  s.executables = ["pdoc"]
  s.default_executable = "pdoc"
  
  s.test_files = Dir['test/**/*.rb']
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["CHANGELOG", "README.markdown"]
  s.add_dependency("BlueCloth", ["> 0.0.0"])
  s.add_dependency("treetop", ["> 0.0.0"])
  s.add_dependency("oyster", ["> 0.0.0"])
end

