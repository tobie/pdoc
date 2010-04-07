module PDoc
  require 'yaml'
  
  class Runner
    def initialize(*source_files)
      options              = source_files.last.is_a?(Hash) ? source_files.pop : {}
      @source_files        = source_files.empty? ? options[:source_files] : source_files
      @output_directory    = File.expand_path(options.delete(:destination) || OUTPUT_DIR)
      @generator           = options.delete(:generator) || Generators::Html::Website
      @parser              = Parser
      @serializer          = Serializer
      @bust_cache          = options.delete(:bust_cache) || false
      Models::Entity.repository_url = options.delete(:repository_url)
      @generator_options = options
      
    end
    
    def serialize(files)
      files.each do |path|
        File.open(pdoc_file(path), "w+") do |f|
          f << serialize_file(path)
        end
      end
    end
    
    def deserialize(files)
      results = []
      files.each do |file|
        file = pdoc_file(file)
        File.open(file) do |y|
          YAML.load_documents(y) { |doc| results << doc }
        end
      end
      results
    end
    
    def new_files
      @source_files.select do |path|
        pdoc = pdoc_file(path)
        !File.exist?(pdoc) || File.mtime(path) > File.mtime(pdoc)
      end
    end
    
    def run
      puts
      puts "    Markdown parser:     #{@generator_options[:markdown_parser]}"
      puts "    Syntax highlighter:  #{@generator_options[:syntax_highlighter]}"
      puts "    Pretty urls:         #{@generator_options[:pretty_urls]}"
      puts "    Repository url:      #{Models::Entity.repository_url}"
      puts "    Index page:          #{@generator_options[:index_page]}"
      puts "    Output directory:    #{@output_directory}\n\n"
      
      files = @bust_cache ? @source_files : new_files
      if files.empty?
        puts "    Restoring serialized documentation from cache.\n\n"
      else
        puts "    Parsing JS files for PDoc comments:"
        start_time = Time.new
        serialize(files)
        puts "    Finished parsing files in #{Time.new - start_time} seconds.\n\n"
      end

      
      start_time = Time.new
      data = deserialize(@source_files)
      root = Treemaker.new(data).root
      puts "    Building documentation tree. Finished in #{Time.new - start_time} seconds.\n\n"
      
      start_time = Time.new
      puts "    Building website:"
      @generator.new(root, @generator_options).render(@output_directory)
      puts "\n    Finished building website in #{Time.new - start_time} seconds.\n\n"
    end
    
    private
      def serialize_file(path)
        serializer = @serializer.new
        serializer.path = path
        puts "        Parsing #{path}..."
        File.open(path) do |file|
          @parser.new(file.read).parse.each do |fragment|
            fragment.serialize(serializer)
          end
        end
        serializer
      end

      def pdoc_file(path)
        name = '.' << File.basename(path, '.js') << '.pdoc.yaml'
        File.expand_path(File.join(File.dirname(path), name))
      end
  end
  
  class Serializer
    attr_accessor :path
    def initialize
      @doc_fragments = []
    end
    
    def <<(fragment)
      fragment = "---\n#{fragment}"
      fragment << "\nfile: #{path}"
      @doc_fragments << fragment
    end
    
    def to_s
      @doc_fragments.join("\n\n")
    end
  end
end