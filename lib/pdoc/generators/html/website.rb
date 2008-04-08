module PDoc
  module Generators
    module Html
      class Website
        def initialize(file)
          @file = file
          string = File.open(@file){ |f| f.read }
          @root = Parser.new(string).parse
          @depth = 0
        end
        
        # Generates the website to the specified directory.
        def render(output = OUTPUT_DIR)
          Dir.chdir(File.expand_path(output))
          Page.new("index", "layout", variables).render_to_file("index.html")
          
          @root.sections.each do |section|
            @depth = 0
            mkdir(section.name)
            dest = "#{section.id}.html"
            DocPage.new("section", variables.merge(:doc_instance => section)).render_to_file(dest)
            section.children.each{ |d| build_tree(d) }
          end
          
          copy_assets
          
          dest = File.join("javascripts", "application.js")
          Page.new("application.js", false, variables).render_to_file(dest)
        end
        
        # Copies the content of the assets folder to the generated website's
        # root directory.
        def copy_assets
          cp_r Dir.glob(File.join(TEMPLATES_DIR, "html", "assets", "**")), '.'
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
            {:root => @root, :depth => @depth}
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