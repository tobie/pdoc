module PDoc
  module Models
    class Base
      @@subclasses_by_type = {}
      
      def self.instantiate(attributes)
        @@subclasses_by_type[attributes['type']].new(attributes)
      end
      
      attr_accessor :parent
      attr_reader   :description
      attr_reader   :id
      attr_reader   :type
      
      def initialize(attributes = {})
        attributes.each { |k, v| instance_variable_set("@#{k}", v) }
      end
      
      def register_on(registry)
        registry[id] = self
      end
      
      def short_description
        @short_description ||= description.split(/\n\n/).first
      end
      
      def deprecated?
        return !!@deprecated if @deprecated
        parent.respond_to?(:deprecated?) ? parent.deprecated? : false
      end
      
      def full_name
        @id
      end
      
      def name
        @name ||= @id.match(/[\w\d\$]+$/)[0]
      end
      
      def ancestor_of?(obj)
        while obj = obj.parent
          return true if obj == self
        end 
        false
      end
      
      def descendant_of?(obj)
        obj.ancestor_of?(self)
      end
      
      def inspect
        "#<#{self.class} #{id}>"
      end
    end
  end
end