require 'pdoc/error'

module PDoc
  class Fragment
    PREFIX_REGEXP = /^\s*\*?\s*/
    
    attr_reader :line_number
    def initialize(string, line_number)
      @line_number = line_number
      @string = string
    end
    
    def normalized_lines
      # Cleans up the text by removing opening and closing comment tags
      # and removing the prefix off of every line.
      # Raises and error if prefix are inconsistent. (Prefix is calculated
      # by looking at line 2 of the comment)
      results = []
      lines.each_with_index do |line, index|
        if index == 0                              # first line
          results << line.sub(/\s*\/\*\*\s*/, '')  # remove opening /**
        elsif index == lines.size - 1              # last line
          results << line.sub(/\s*\*\*?\/\s*/, '') # remove closing **/
        elsif line =~ prefix_regexp                # correctly prefixed lines
          results << line.sub(prefix_regexp, '')   # remove optional prefix
        else
          raise InconsistentPrefixError.new(self, line, index)
        end
      end
      results
    end
    
    def prefix
      PREFIX_REGEXP.match(lines[1])[0] if lines.size > 2
    end
    
    def prefix_regexp
      @prefix_regexp ||= Regexp.new('^' << Regexp.escape(prefix))
    end
    private(:prefix_regexp)
    
    def lines
      @lines ||= @string.split("\n")
    end
    
    class InconsistentPrefixError < PDocError
      def initialize(fragment, line, index)
        @fragment = fragment
        actual = PREFIX_REGEXP.match(line)[0].inspect
        msg = "Inconsistent prefixing at line ##{fragment.line_number + index}."
        msg << "Expected prefix is: #{fragment.prefix.inspect}, actual prefix is: #{actual}"
        super(msg)
      end
    end
  end
end
