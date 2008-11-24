module PDoc
  module Generators
    class AbstractGenerator
      attr_reader :options, :root
      def initialize(parser_output, options = {})
        @root = parser_output
        @options = options
      end
      
      # Creates a new directory with read, write and execute permission.
      def mkdir(name)
        Dir.mkdir(name, 0755)
      end
      
      def log(msg)
        puts "    #{msg}"
      end
    end
  end
end