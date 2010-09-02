# encoding: utf-8
module PDoc
  module Generators
    module Html
      class Page

        include Helpers::BaseHelper
        include Helpers::LinkHelper
        
        def initialize(template, layout, variables = {})
          @template = template
          @layout = layout
          assign_variables(variables)
        end
        
        # Renders the page as a string using the assigned layout.
        def render
          if @layout
            @content_for_layout = Template.new(@template, @templates_directory).result(binding)
            Template.new(@layout, @templates_directory).result(binding)
          else
            Template.new(@template, @templates_directory).result(binding)
          end
        end
        
        # Creates a new file and renders the page to it
        # using the assigned layout.
        def render_to_file(filename)
          filename ||= ""
          FileUtils.mkdir_p(File.dirname(filename))
          File.open(filename, "w+") { |f| f << render }
        end
        
        def include(path, options = {})
          r = options.collect { |k, v| "#{k.to_s} = options[:#{k}]" }.join(';')
          
          if options[:collection]
            # XXX This assumes that `options[:collection]` and `options[:object]` are mutually exclusive
            options[:collection].map { |object| b = binding; b.eval(r); Template.new(path, @templates_directory).result(b) }.join("\n")
          else
            b = binding
            b.eval(r)
            Template.new(path, @templates_directory).result(b)
          end
        end
        
        private
          def assign_variables(variables)
            variables.each { |key, value| instance_variable_set("@#{key}", value) }
          end
      end

      class DocPage < Page
        include Helpers::LinkHelper, Helpers::CodeHelper, Helpers::MenuHelper
        
        attr_reader :doc_instance, :depth, :root
        
        def initialize(template, layout = "layout", variables = {})
          if layout.is_a?(Hash)
            variables = layout
            layout = "layout"
          end
          super(template, layout, variables)
        end
        
        def htmlize(markdown)
          super(auto_link_content(markdown))
        end
      end
      
    end
  end
end
