module PDoc
  module Models
    class ClassMethod < Entity
      def attach_to_parent(parent)
        parent.class_methods << self
      end
    end
  end
end