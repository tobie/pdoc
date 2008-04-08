module PDoc
  module Generators
    module Html
      class Page
        include Helpers
        
        attr_reader :doc_instance, :depth, :root
        
        def initialize(template, layout, variables = {})
          @template = template
          @layout = layout
          assign_variables(variables)
          @title = title
        end
        
        # Renders the page as a string using the assigned layout.
        def render
          if @layout
            @content_for_layout = find_template(@template).result(binding)
            find_template(@layout).result(binding)
          else
            find_template(@template).result(binding)
          end
        end
        
        # Creates a new file and renders the page to it
        # using the assigned layout.
        def render_to_file(filename)
          File.open(filename, "w+") do |f|
            f << render
          end
        end
        
        # Web page's title
        def title
          ""
        end
        
        private
          def assign_variables(variables)
            variables.each { |key, value| instance_variable_set("@#{key}", value) }
          end
          
          def find_template(name)
            name = File.join(name.split("/"))
            path = File.expand_path(File.join(TEMPLATES_DIR, "html", "#{name}.erb"), DIR)
            ERB.new(IO.read(path), nil, '%')
          end
      end
      
      class DocPage < Page
        def initialize(template, variables = {})
          super(template, "layout", variables)
        end
        
        # Web page's title
        def title
          " | #{@doc_instance.full_name} #{@doc_instance.type}"
        end
      end
    end
  end
end