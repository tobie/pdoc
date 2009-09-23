module PDoc
  module Models
    class Class < Entity
      include Container
      
      def attach_to_parent(parent)
        parent.classes << self
      end
      
      def instance_methods
        @instance_methods ||= []
      end
      
      def instance_properties
        @instance_properties ||= []
      end
    end
  end
end
