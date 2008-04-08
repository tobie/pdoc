module PDoc
  class Runner
    def initialize(source)
      @generator = Generators::Html::Website
      @parser_output = parse(source)
    end
    
    def parse(source)
      string = File.open(source){ |f| f.read }
      Parser.new(string).parse
    end
    
    def render(output = OUTPUT_DIR)
      @generator.new(@parser_output).render(output)
    end
  end
end