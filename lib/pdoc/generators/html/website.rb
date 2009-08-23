module PDoc
  module Generators
    module Html
      
      unless defined? TEMPLATES_DIRECTORY
        TEMPLATES_DIRECTORY = File.join(TEMPLATES_DIR, "html")
      end
      
      class Website < AbstractGenerator
        
        include Helpers::BaseHelper
        
        def initialize(parser_output, options = {})
          super
          @templates_directory = options[:templates] || TEMPLATES_DIRECTORY
          @index_page = options[:index_page]
          load_custom_helpers
        end
        
        def load_custom_helpers
          begin
            require File.join(@templates_directory, "helpers")
          rescue LoadError => e
            return nil
          end
          self.class.__send__(:include, Helpers::BaseHelper)
          Page.__send__(:include, Helpers::BaseHelper)
          Helpers.constants.map(&Helpers.method(:const_get)).each(&DocPage.method(:include))
        end
        
        # Generates the website to the specified directory.
        def render(output)
          @depth = 0
          path = File.expand_path(output)
          FileUtils.mkdir_p(path)
          Dir.chdir(path)
          vars = variables.merge(:index_page_content => index_page_content)
          DocPage.new("index", "layout", vars).render_to_file("index.html")
          
          root.sections.each do |section|
            @depth = 0
            mkdir(section.name.downcase)
            render_template('section', "#{section.id}.html", {:doc_instance => section})
          end
          
          root.utilities.each(&method(:render_utility))
          root.namespaces.each(&method(:render_namespace))
          
          copy_assets
          
          dest = File.join("javascripts", "item_index.js")
          DocPage.new("item_index.js", false, variables).render_to_file(dest)
        end
        
        def render_template(template, dest, var = {})
          log "\c[[F\c[[K    Rendering: #{dest}"
          DocPage.new(template, variables.merge(var)).render_to_file(dest)
        end
        
        # Copies the content of the assets folder to the generated website's
        # root directory.
        def copy_assets
          FileUtils.cp_r(Dir.glob(File.join(@templates_directory, "assets", "**")), '.')
        end
        
        def render_namespace(object)
          template, path = find_template_name(object), path(object)
          @depth = path.size
          dest = File.join(path, "#{object.id}.html")
          render_template(template, dest, {:doc_instance => object})
        end
        alias :render_utility :render_namespace
        
        private
          def variables
            {:root => root, :depth => @depth, :templates_directory => @templates_directory}
          end
          
          def path(object)
            [object.section.name.downcase].concat(object.namespace_string.downcase.split('.'))
          end
          
          def find_template_name(obj)
            obj.is_a?(Documentation::Utility) ? "utility" : "namespace"
          end
          
          def index_page_content
            @index_page ? htmlize(File.read(@index_page)) : nil
          end
      end
    end
  end
end
