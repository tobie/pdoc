module PDoc
  module Models
    class Signature < Entity
      def attach_to_parent(parent)
        parent.signatures << self
      end
    end
  end
end