module PDoc
  module Models
    class InstanceMethod < Entity
      include Callable
      attr_accessor :functionalized_self
      def attach_to_parent(parent)
        parent.instance_methods << self
      end
    end
  end
end