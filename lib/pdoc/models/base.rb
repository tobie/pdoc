module PDoc
  module Models
    class Base
      @@subclasses_by_type = {}
      
      def self.instantiate(attributes)
        @@subclasses_by_type[attributes[:type]].new(attributes)
      end
      
      attr_accessor :parent
      attr_reader   :description
      attr_reader   :id
      
      def initialize(attributes = {})
        attributes.each { |k, v| instance_variable_set(k, v) }
      end
      
      def register_on(registry)
        registry[id] = self
      end
    end
  end
end