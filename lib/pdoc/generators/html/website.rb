module PDoc
  module Generators
    module Html
      
      unless defined? TEMPLATES_DIRECTORY
        TEMPLATES_DIRECTORY = File.join(TEMPLATES_DIR, "html")
      end
      
      class Website < AbstractGenerator
        
        include Helpers::BaseHelper
        
        class << Website
          attr_accessor :syntax_highlighter
          attr_accessor :markdown_parser
        end
        
        def initialize(parser_output, options = {})
          super
          @templates_directory = File.expand_path(options[:templates] || TEMPLATES_DIRECTORY)
          @index_page = options[:index_page] && File.expand_path(options[:index_page])
          Website.syntax_highlighter = SyntaxHighlighter.new(options[:syntax_highlighter])
          set_markdown_parser(options[:markdown_parser])
          load_custom_helpers
        end
        
        def set_markdown_parser(parser = nil)
          parser = :rdiscount if parser.nil?
          case parser.to_sym
          when :rdiscount
            require 'rdiscount'
            Website.markdown_parser = RDiscount
          when :bluecloth
            require 'bluecloth'
            Website.markdown_parser = BlueCloth
          when :maruku
            require 'maruku'
            Website.markdown_parser = Maruku
          else
            raise "Requested unsupported Markdown parser: #{parser}."
          end
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
          
          render_index
          copy_assets
          
          root.sections.each do |section|
            @depth = 0
            render_template('section', { :doc_instance => section })
          end

          dest = File.join("javascripts", "item_index.js")
          DocPage.new("item_index.js", false, variables).render_to_file(dest)
        end
        
        def render_index
          vars = variables.merge(:index_page_content => index_page_content, :home => true)
          DocPage.new('index', 'layout', vars).render_to_file('index.html')
        end
        
        def render_template(template, var = {})
          @depth += 1
          doc = var[:doc_instance]
          dest = path(doc, var[:methodized])
          log "\c[[F\c[[K    Rendering: #{dest}"
          FileUtils.mkdir_p(dest)
          DocPage.new(template, variables.merge(var)).render_to_file(File.join(dest, 'index.html'))
          render_children(doc)
          @depth -= 1
        end
        
        def render_children(obj)
          if obj.is_a?(Documentation::Section)
            obj.children.each { |c| is_leaf?(c) ? render_leaf(c) : render_node(c) }
          else
            obj.children.select { |c| c.namespace === obj }.each(&method(:render_node))
          end
          
          render_leaf(obj.constructor) if obj.respond_to?(:constructor) && obj.constructor
          
          obj.instance_methods.each(&method(:render_leaf))    if obj.respond_to?(:instance_methods)
          obj.instance_properties.each(&method(:render_leaf)) if obj.respond_to?(:instance_properties)
          obj.klass_properties.each(&method(:render_leaf))    if obj.respond_to?(:klass_properties)
          obj.constants.each(&method(:render_leaf))           if obj.respond_to?(:constants)
          
          if obj.respond_to?(:klass_methods)
            obj.klass_methods.each do |m|
              render_leaf(m)
              render_leaf(m, true) if m.methodized?
            end
          end
        end
        
        # Copies the content of the assets folder to the generated website's
        # root directory.
        def copy_assets
          FileUtils.cp_r(Dir.glob(File.join(@templates_directory, "assets", "**")), '.')
        end
        
        def render_leaf(object, methodized = false)
          is_proto_prop = is_proto_prop?(object, methodized)
          @depth += 1 if is_proto_prop
          render_template('leaf', { :doc_instance => object, :methodized => methodized })
          @depth -= 1 if is_proto_prop
        end
        
        def render_node(object)          
          render_template('node', { :doc_instance => object })
        end
        
        private
          def variables
            {:root => root, :depth => @depth, :templates_directory => @templates_directory}
          end
          
          def path(object, methodized = false)
            return object.name.downcase if object.is_a?(Documentation::Section)
            path = [object.section.name.downcase].concat(object.namespace_string.downcase.split('.'))
            path << 'prototype' if is_proto_prop?(object, methodized)
            File.join(path, object.id)
          end
          
          def is_proto_prop?(object, methodized = false)
            object.is_a?(Documentation::InstanceMethod) ||
              object.is_a?(Documentation::InstanceProperty) ||
                (methodized && object.is_a?(Documentation::KlassMethod))
          end
          
          def is_leaf?(object)
            object.is_a?(Documentation::Method) ||
              object.is_a?(Documentation::Property) ||
                object.is_a?(Documentation::Constant)
          end
          
          def index_page_content
            @index_page ? htmlize(File.read(@index_page)) : nil
          end
      end
    end
  end
end
