module PDoc
  module Models
    module Container
      # returns an array of Namespace objects belonging to this section
      def namespaces
        @namespaces ||= []
      end
    
      # returns an array of Class objects belonging to this section
      def classes
        @classes ||= []
      end
    
      # returns an array of Mixin objects belonging to this section
      def mixins
        @mixins ||= []
      end
    end
  end
end