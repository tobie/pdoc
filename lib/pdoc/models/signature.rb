module PDoc
  module Models
    class Signature < Entity
      attr_reader :return_value
      def attach_to_parent(parent)
        parent.signatures << self
      end
      
      #TODO API cleanup
      
      def to_s
        @signature
      end
      
      def name
        @signature
      end
    end
  end
end