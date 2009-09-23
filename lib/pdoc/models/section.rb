module PDoc
  module Models
    class Section < Base
      include Container
      
      def attach_to_parent(parent)
        parent.sections << self
      end
      
      # returns an array of Function objects belonging to this section
      def utilities
        @utilities ||= []
      end
    end
  end
end
