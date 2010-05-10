module PDoc
  module Models
    class InstanceMethod < Entity
      include Callable
      attr_accessor :functionalized_self
      def attach_to_parent(parent)
        parent.instance_methods << self
      end
      
      def to_hash
        super.merge({
          :functionalized_self => functionalized_self
        })
      end
    end
  end
end