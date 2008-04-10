module PDoc
  module Generators
    module Html
      class DescriptionParser
        def initialize(description)
          @description = description
        end
        
        def to_html
          str = blocks.map do |block|
            block.match(/\s{4}/) ? CodeBlock.new(block).to_html : block
          end.join("\n\n")
          BlueCloth.new(str).to_html
        end
        
        def blocks
          @description.split(/\n{2,}/)
        end
      end
      
      class DescriptionParser::CodeBlock
        include Helpers::BaseHelper
        
        def initialize(string)
          @string = string
          @language = "javascript"
        end
        
        def lines
          @string.split(/\n/).map{ |l| l.sub(/\s{4}/, '') }
        end
        
        def content
          l = lines
          if match = l.first.match(/^lang(?:uage)?:\s*(\w+)\s*$/)
            @language = match[1]
            l.shift
          end
          escape_html(l.join("\n"))
        end
        
        def to_html
          content_tag(:pre, content_tag(:code, content, :class => @language))
        end
        
        def escape_html(string)
          string.gsub("<", "&lt;").gsub(">", "&gt;")
        end
      end
    end
  end
end