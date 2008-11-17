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
        "lib/pdoc/runner.rb",
        
        "lib/pdoc/generators.rb",
        "lib/pdoc/generators/html.rb",
        "lib/pdoc/generators/html/bluecloth_extension.rb",
        "lib/pdoc/generators/html/helpers.rb",
        "lib/pdoc/generators/html/template.rb",
        "lib/pdoc/generators/html/page.rb",
        "lib/pdoc/generators/html/website.rb",
        
        "lib/pdoc/parser.rb",
        "lib/pdoc/parser/treetop_files/argument_description.treetop",
        "lib/pdoc/parser/treetop_files/basic.treetop",
        "lib/pdoc/parser/treetop_files/description.treetop",
        "lib/pdoc/parser/treetop_files/documentation.treetop",
        "lib/pdoc/parser/treetop_files/ebnf_arguments.treetop",
        "lib/pdoc/parser/treetop_files/ebnf_expression.treetop",
        "lib/pdoc/parser/treetop_files/ebnf_javascript.treetop",
        "lib/pdoc/parser/treetop_files/events.treetop",
        "lib/pdoc/parser/treetop_files/section_content.treetop",
        "lib/pdoc/parser/treetop_files/tags.treetop",
        
        "lib/pdoc/parser/basic_nodes.rb",
        "lib/pdoc/parser/tags_nodes.rb",
        "lib/pdoc/parser/argument_description_nodes.rb",
        "lib/pdoc/parser/description_nodes.rb",
        "lib/pdoc/parser/ebnf_arguments_nodes.rb",
        "lib/pdoc/parser/ebnf_expression_nodes.rb",
        "lib/pdoc/parser/section_content_nodes.rb",
        "lib/pdoc/parser/documentation_nodes.rb"]
  
  s.test_files = Dir['test/**/*.rb']
  s.rdoc_options = ["--main", "README.markdown"]
  s.extra_rdoc_files = ["CHANGELOG", "README.markdown"]
  s.add_dependency("BlueCloth", ["> 0.0.0"])
  s.add_dependency("treetop", ["> 0.0.0"])
end

