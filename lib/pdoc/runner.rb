module PDoc
  class Runner
    def initialize(*source_files)
      options              = source_files.last.is_a?(Hash) ? source_files.pop : {}
      @source_files        = source_files
      @output_directory    = File.expand_path(options[:output] || OUTPUT_DIR)
      @templates_directory = options[:templates] && File.expand_path(options[:templates])
      @generator           = options[:generator] || Generators::Html::Website
      @parser              = Parser.new(source)
    end
    
    def source
      @source_files.map { |path| File.open(path) { |f| f.read } }.join("\n\n")
    end
    
    def parse
      Thread.new(@parser) do |parser|
        log "Parsing source files: #{@source_files * ', '}."
        log 'Processing... 0%'
        i = 0
        begin
          dots = ('.' * i) << (' ' * (3-i)) 
          log "\c[[F    Processing#{dots} #{parser.completion_percentage}"
          i =  i == 3 ? 0 : i + 1
          sleep 0.1
        end until parser.finished?
      end
      start_time = Time.new
      @parser_output = @parser.parse
      log "\c[[F    Parsing completed in #{Time.new - start_time} seconds.\n\n"
    end
    
    def render
      log "Generating documentation to: #{@output_directory}.\n\n"
      start_time = Time.new
      @generator.new(@parser_output, :templates => @templates_directory).render(@output_directory)
      log "\c[[F    Documentation generated in #{Time.new - start_time} seconds."
    end
    
    def run
      puts "\n"
      parse
      render
      log summary
    end
    
    def summary
      <<-EOS
  
    Summary:
      Sections:            #{@parser_output.sections.length}
      Utilities:           #{@parser_output.utilities.length}
      Namespaces:          #{@parser_output.namespaces.length}
      Mixins:              #{@parser_output.mixins.length}
      Classes:             #{@parser_output.klasses.length}
      Constructor methods: #{@parser_output.constructors.length}
      Constants:           #{@parser_output.constants.length}
      Class methods:       #{@parser_output.klass_methods.length}
      Instance methods:    #{@parser_output.instance_methods.length}
      Class properties:    #{@parser_output.klass_properties.length}
      Instance properties: #{@parser_output.instance_properties.length}

      EOS
    end
    
    def log(message)
      puts "    #{message}"
    end
  end
end
