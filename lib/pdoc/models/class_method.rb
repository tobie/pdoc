module PDoc
  module Models
    class ClassMethod < Entity
      include Callable
      attr_accessor :methodized_self
      def attach_to_parent(parent)
        parent.class_methods << self
      end
      
      def to_hash
        super.merge({
          :methodized_self => methodized_self
        })
      end
    end
  end
end