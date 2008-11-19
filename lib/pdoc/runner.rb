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
      log "Parsing source files: #{@source_files * ', '}."
      start_time = Time.new
      @parser_output = @parser.parse
      log "Parsing completed in #{Time.new - start_time} seconds."
    end
    
    def render
      log "Generating documentation to: #{@output_directory}."
      start_time = Time.new
      @generator.new(@parser_output, :templates => @templates_directory).render(@output_directory)
      log "Documentation generated in #{Time.new - start_time} seconds."
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
