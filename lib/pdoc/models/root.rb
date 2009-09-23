module PDoc
  module Models
    class Root
      include Container
      
      # returns an array of Function objects belonging to this section
      def utilities
        @utilities ||= []
      end
      
      def sections
        @sections ||= []
      end
      
      def registry
        @registry ||= {}
      end
      
      def find(id)
        registry[id]
      end
    end
  end
end
