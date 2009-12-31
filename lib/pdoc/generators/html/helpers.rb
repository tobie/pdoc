module PDoc
  module Generators
    module Html
      module Helpers
        module BaseHelper
          def content_tag(tag_name, content, attributes = {})
            "<#{tag_name}#{attributes_to_html(attributes)}>#{content}</#{tag_name}>"
          end

          def img_tag(filename, attributes = {})
            attributes.merge! :src => "#{path_prefix}images/#{filename}"
            tag(:img, attributes)
          end

          def tag(tag_name, attributes = {})
            "<#{tag_name}#{attributes_to_html(attributes)} />"
          end
          
          def link_to(name, path, attributes={})
            content_tag(:a, name, attributes.merge(:href => path))
          end
          
          def htmlize(markdown)
            markdown = Website.syntax_highlighter.parse(markdown)
            Website.markdown_parser.new(markdown).to_html
          end
          
          # Gah, what an ugly hack.
          def inline_htmlize(markdown)
            htmlize(markdown).gsub(/^<p>/, '').gsub(/<\/p>$/, '')
          end
          
          def javascript_include_tag(*names)
            names.map do |name|
              attributes = {
                :src => "#{path_prefix}javascripts/#{name}.js",
                :type => "text/javascript",
                :charset => "utf-8"
              }
              content_tag(:script, "", attributes)
            end.join("\n")
          end

          def stylesheet_link_tag(*names)
            names.map do |name|
              attributes = {
                :href => "#{path_prefix}stylesheets/#{name}.css",
                :type => "text/css",
                :media => "screen, projection",
                :charset => "utf-8",
                :rel => "stylesheet"
              }
              tag(:link, attributes)
            end.join("\n")
          end
          
          private
            def attributes_to_html(attributes)
              attributes.map { |k, v| v ? " #{k}=\"#{v}\"" : "" }.join
            end
        end
        
        module LinkHelper
          def path_prefix
            "../" * depth
          end

          def path_to(obj, methodized = false)
            path_prefix << raw_path_to(obj, methodized)
          end
          
          def raw_path_to(obj, methodized = false)
            return "#{obj.name.downcase}/" if obj.is_a?(Documentation::Section)
            
            path = [obj.section.name.downcase].concat(obj.namespace_string.downcase.split('.')).join("/")
            if obj.is_a?(Documentation::InstanceMethod) || obj.is_a?(Documentation::InstanceProperty)
              "#{path}/prototype/#{obj.id.downcase}/"
            elsif obj.is_a?(Documentation::KlassMethod)
              methodized ? "#{path}/prototype/#{obj.id.downcase}/" : "#{path}/#{obj.id.downcase}/"
            else
              "#{path}/#{obj.id.downcase}/"
            end
          end
          
          # deprecated
          def path_to_section(obj)
            "#{obj.name.downcase}/"
          end
          
          def section_from_name(name)
            root.sections.find { |section| section.name == name }
          end          

          def auto_link(obj, options = {})
            if obj.is_a?(String)
              original = obj
              obj = root.find_by_name(obj)
              return original unless obj
            end
            name = options.delete(:name) == :short ? obj.name : obj.full_name
            type = obj.is_a?(Documentation::KlassMethod) && options[:methodized] ? 'instance method' : obj.type
            path = path_to(obj, options.delete(:methodized))
            link_to(name, path, { :title => "#{obj.full_name} (#{type})" }.merge(options))
          end
          
          def auto_link_code(obj, options = {})
            "<code>#{auto_link(obj, options)}</code>"
          end

          def auto_link_content(content)
            return '' if content.nil?
            content.gsub!(/\[\[([a-zA-Z]+)\s+section\]\]/) do |m|
              result = auto_link(section_from_name($1), :name => :long)
              result
            end
            content.gsub(/\[\[([a-zA-Z$\.#]+)(?:\s+([^\]]+))?\]\]/) do |m|
              if doc_instance = root.find_by_name($1)
                $2 ? link_to($2, path_to(doc_instance)) : auto_link_code(doc_instance, :name => :long)
              else
                $1
              end
            end
          end
          
          def auto_link_types(types, options = {})
            types = types.split(/\s+\|\s+/) if types.is_a?(String)
            types.map do |t|
              if match = /^\[([\w\d\$\.\(\)#]*[\w\d\$\(\)#])...\s*\]$/.match(t) # e.g.: [Element...]
                "[#{auto_link(match[1], options)}…]"
              else
                auto_link(t, options)
              end
            end
          end
          
          def dom_id(obj)
            "#{obj.id}-#{obj.type.gsub(/\s+/, '_')}"
          end
        end
        
        module CodeHelper
          def methodize_signature(sig)
            sig.sub(/\.([\w\d\$]+)\((.*?)(,\s*|\))/) do
              first_arg = $2.to_s.strip
              prefix = first_arg[-1, 1] == '[' ? '([' : '('
              rest = $3 == ')' ? $3 : ''
              "##{$1}#{prefix}#{rest}"
            end
          end
          
          def methodize_full_name(obj)
            obj.full_name.sub(/\.([^.]+)$/, '#\1')
          end
          
          def method_synopsis(object, methodized = false)
            result = []
            object.ebnf_expressions.each do |ebnf|
              if object.is_a?(Documentation::Constructor)
                result << "#{object.full_name}#{ebnf.args.text_value}"
              else
                types = auto_link_types(ebnf.returns, :name => :long).join(' | ')
                if object.is_a?(Documentation::KlassMethod) && object.methodized? && methodized
                  result << "#{methodize_signature(ebnf.signature)} &rarr; #{types}"
                else
                  result << "#{ebnf.signature} &rarr; #{types}"
                end
              end
            end
            result
          end
          
          def breadcrumb(obj, options)
            result = []
            original_obj = obj
            begin
              result << auto_link(obj, options)
            end while obj = obj.namespace
            unless original_obj.is_a?(Documentation::Section)
              result << auto_link(original_obj.section, options)
            end
            result.reverse!
          end
        end
        
        module MenuHelper
          def menu(obj)
            html = menu_item(obj, :name => :long)
            
            if !obj.children.empty?
              list_items = obj.children.map { |n| menu(n) }.join("\n")
              li_class_names = obj.type == "section" ? "menu-section" : ""
              html << content_tag(:ul, list_items, :class => li_class_names)
            elsif obj == doc_instance && obj.respond_to?(:constants)
              html << submenu(obj)
            elsif doc_instance && doc_instance.respond_to?(:namespace)
              namespace = doc_instance.namespace
              html << submenu(namespace) if namespace == obj && obj.respond_to?(:constants)
            end
            
            content_tag(:li, html)
          end
          
          def menu_item(obj, options = {})
            options = options.dup
            options[:class] = class_names_for(obj, options)
            content_tag(:div, auto_link(obj, options), :class => 'menu-item')
          end
          
          def submenu(obj)
            items = []
            if obj.respond_to?(:constructor) && obj.constructor
              items << content_tag(:li, menu_item(obj.constructor, :name => :short))
            end
            [ :constants,
              :klass_methods,
              :klass_properties,
            ].each do |prop|
              obj.send(prop).map { |item| items << content_tag(:li, menu_item(item, :name => :short)) }
            end
            instance_methods = obj.instance_methods.dup
            methodized_methods = obj.klass_methods.select { |m| m.methodized? }
            instance_methods.concat(methodized_methods)
            instance_methods = instance_methods.sort_by { |e| e.name }
            instance_methods.map do |item|
              items << content_tag(:li, menu_item(item, :name => :short, :methodized => true ))
            end
            obj.instance_properties.map { |item| items << content_tag(:li, menu_item(item, :name => :short)) }
            
            content_tag(:ul, items.join("\n"))
          end
          
          def class_names_for(obj, options = {})
            classes = []
            if obj.is_a?(Documentation::KlassMethod) && obj.methodized? && options[:methodized]
              classes << 'instance-method'
            else
              classes << obj.type.gsub(/\s+/, '-')
            end
            classes << "deprecated" if obj.deprecated?
            if doc_instance
              if obj == doc_instance
                classes << "current"
              elsif doc_instance.namespace == obj ||
                obj.descendants.include?(doc_instance) ||
                  obj.descendants.include?(doc_instance.namespace)
                classes << "current-parent"
              end
            end
            classes.join(" ")
          end
        end
      end
    end
  end
end
