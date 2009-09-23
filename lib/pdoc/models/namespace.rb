module PDoc
  module Models
    class Namespace < Entity
      include Container
      
      def attach_to_parent(parent)
        parent.namespaces << self
      end

      def class_methods
        @class_methods ||= []
      end

      def class_properties
        @class_properties ||= []
      end
    end
  end
end
