module PDoc
  module Models
    class Mixin < Entity
      def attach_to_parent(parent)
        parent.mixins << self
      end
    end
  end
end