module PDoc
  module Models
    class Utility < Entity
      def attach_to_parent(parent)
        parent.utilities << self
      end
    end
  end
end