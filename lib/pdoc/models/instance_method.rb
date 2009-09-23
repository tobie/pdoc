module PDoc
  module Models
    class InstanceMethod < Entity
      def attach_to_parent(parent)
        parent.instance_methods << self
      end
    end
  end
end