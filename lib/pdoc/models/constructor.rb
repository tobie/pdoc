module PDoc
  module Models
    class Constructor < Entity
      def attach_to_parent(parent)
        parent.constructor = self
      end
    end
  end
end
