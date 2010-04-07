module PDoc
  module Models
    class Object < Entity
      include Container
      attr_accessor :constructor
      attr_accessor :superclass
      def attach_to_parent(parent)
        parent.children << self
      end
      
      def subclasses
        @subclasses ||= []
      end
      
      def subclasses?
        @subclasses && !@subclasses.empty?
      end
    end
  end
end
