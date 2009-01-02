module PDoc
  module Generators
    module Html
      class Website < AbstractGenerator
        # Generates the website to the specified directory.
        def render(output)
          @depth = 0
          path = File.expand_path(output)
          FileUtils.mkdir_p(path)
          Dir.chdir(path)
          DocPage.new("index", "layout", variables).render_to_file("index.html")
          root.sections.each do |section|
            @depth = 0
            mkdir(section.name)
            render_template('section', "#{section.id}.html", {:doc_instance => section})
            section.children.each{ |d| build_tree(d) }
          end
          
          copy_assets
          
          dest = File.join("javascripts", "item_index.js")
          DocPage.new("item_index.js", false, variables).render_to_file(dest)
        end
        
        def render_template(template, dest, var = {})
          DocPage.new(template, variables.merge(var)).render_to_file(dest)
          log "\c[[F\c[[K    Rendering: #{dest}"
        end
        
        # Copies the content of the assets folder to the generated website's
        # root directory.
        def copy_assets
          FileUtils.cp_r(Dir.glob(File.join(@options[:templates] || TEMPLATES_DIR, "html", "assets", "**")), '.')
        end
        
        def build_tree(object)
          @depth += 1
          unless object.children.empty?
            mkdir(File.join(path(object), object.id))
            object.children.each { |d| build_tree(d) }
          end
          template = find_template_name(object)
          dest = File.join(path(object), "#{object.id}.html")
          render_template(template, dest, {:doc_instance => object})
          @depth -= 1
        end
        
        private
          def variables
            {:root => root, :depth => @depth, :templates_directory => File.join(options[:templates] || TEMPLATES_DIR, "html")}
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
