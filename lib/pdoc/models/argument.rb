module PDoc
  module Models
    class Argument < Entity
      attr_reader :name
      attr_reader :default_value
      attr_reader :optional
      attr_reader :types
      
      def attach_to_parent(parent)
        parent.arguments << self
      end
      
      # returns the argument's id in the form
      # method_id:argument_name. So, for example:
      # document.querySelectorAll:cssSelector
      def id
        @id ||= "#{parent.id}:#{name}"
      end
      
      def types
        @types ||= []
      end
    end
  end
end