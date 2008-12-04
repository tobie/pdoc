module PDoc
  module Generators
    module Html
      
      unless defined? TEMPLATES_DIRECTORY
        TEMPLATES_DIRECTORY = File.join(TEMPLATES_DIR, "html")
      end
      
      class Website
        def initialize(parser_output, options = {})
          @root = parser_output
          @depth = 0
          
          @templates_directory = options[:templates] || TEMPLATES_DIRECTORY
          require "#{ @templates_directory }/helpers"
          Page.__send__(:include, Helpers::BaseHelper)
          Helpers.constants.map(&Helpers.method(:const_get)).each(&DocPage.method(:include))
        end
        
        # Generates the website to the specified directory.
        def render(output)
          path = File.expand_path(output)
          FileUtils.mkdir_p(path)
          Dir.chdir(path)
          DocPage.new("index", "layout", variables).render_to_file("index.html")
          
          @root.sections.each do |section|
            @depth = 0
            mkdir(section.name)
            dest = "#{section.id}.html"
            DocPage.new("section", variables.merge(:doc_instance => section)).render_to_file(dest)
            section.children.each{ |d| build_tree(d) }
          end
          
          copy_assets
          
          dest = File.join("javascripts", "item_index.js")
          DocPage.new("item_index.js", false, variables).render_to_file(dest)
        end
        
        # Copies the content of the assets folder to the generated website's
        # root directory.
        def copy_assets
          FileUtils.cp_r(Dir.glob(File.join(TEMPLATES_DIR, "html", "assets", "**")), '.')
        end
        
        # Creates a new directory with read, write and execute permission.
        def mkdir(name)
          Dir.mkdir(name, 0755)
        end
        
        def build_tree(object)
          @depth += 1
          unless object.children.empty?
            mkdir(File.join(path(object), object.id))
            object.children.each { |d| build_tree(d) }
          end
          template = find_template_name(object)
          dest = File.join(path(object), "#{object.id}.html")
          DocPage.new(template, variables.merge(:doc_instance => object)).render_to_file(dest)
          @depth -= 1
        end
        
        private
          def variables
            {:root => @root, :depth => @depth, :templates_directory => @templates_directory}
          end
          
          def path(object)
            [object.section.name].concat(object.namespace_string.downcase.split('.'))
          end
          
          def find_template_name(obj)
            obj.is_a?(Documentation::Utility) ? "utility" : "namespace"
          end
      end
    end
  end
end
