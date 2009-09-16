module PDoc
  module Generators
    module Html
      CODE_BLOCK_REGEXP = /(?:\n\n|\A)(?:\s{4,}lang(?:uage)?:\s*(\w+)\s*\n)?((?:\s{4}.*\n+)+)(^\s{0,3}\S|\Z)/
      attr_reader :default_language, :highlighter
      
      class SyntaxHighlighter
        def initialize(options = {})
          @default_language = options[:default_language] ||= :javascript
          @highlighter      = options[:highlighter]      ||= :none
        end
        
        def parse(input)
          input.gsub(CODE_BLOCK_REGEXP) do |block|
            language, codeblock, remainder = $1, $2, $3
            codeblock = codeblock.gsub(/^\s{4}/, '').rstrip
            "\n\n#{highlight_block(codeblock, language)}\n#{remainder}"
          end
        end
        
        def highlight_block(code, language = default_language)
          case highlighter
            when :none
              "<pre><code class=\"#{language}\">#{code}</code></pre>"
            when :coderay
              require 'coderay'
              CodeRay.scan(code, language).div
            when :pygments
              require 'albino'
              Albino.new(code, language).colorize
          else
            raise "Requested unsupported syntax highlighter: #{highlighter}"
          end
        end
      end
    end
  end
end
