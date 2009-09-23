module PDoc
  module Models
    class MethodizedMethod < Entity
      def attach_to_parent(parent)
        parent.class_methods << self
        parent.instance_methods << self
      end
      
      def register_on(registry)
        super
        registry[methodized_id] = self
      end
      
      private
        def methodized_id
          id.sub(/\.([^\.]+)$/, "##$1")
        end
    end
  end
end
