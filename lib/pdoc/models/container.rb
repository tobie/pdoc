module PDoc
  module Models
    module Container
      def children
        @children ||= []
      end
      
      def children?
        @children && !@children.empty?
      end
      
      # returns an array of Namespace objects belonging to this section
      def namespaces
        @namespaces ||= []
      end
      
      def namespaces?
        @namespaces && !@namespaces.empty?
      end
    
      # returns an array of Class objects belonging to this section
      def classes
        @classes ||= []
      end
      
      def classes?
        @classes && !@classes.empty?
      end
    
      # returns an array of Mixin objects belonging to this section
      def mixins
        @mixins ||= []
      end
      
      def mixins?
        @mixins && !@mixins.empty?
      end
      
      def included_mixins
        @included_mixins ||= []
      end
      
      def included_mixins?
        @included_mixins && !@included_mixins.empty?
      end
      
      # returns an array of Function objects belonging to this section
      def utilities
        @utilities ||= []
      end
      
      def utilities?
        @utilities && !@utilities.empty?
      end
      
      # returns an array of constants objects belonging to this section
      def constants
        @constants ||= []
      end
      
      def constants?
        @constants && !@constants.empty?
      end
      
      def class_methods
        @class_methods ||= []
      end
      
      def class_methods?
        @class_methods && !@class_methods.empty?
      end
      
      def class_properties
        @class_properties ||= []
      end
      
      def class_properties?
        @class_properties && !@class_properties.empty?
      end
      
      def instance_methods
        @instance_methods ||= []
      end
      
      def instance_methods?
        @instance_methods && !@instance_methods.empty?
      end
      
      def instance_properties
        @instance_properties ||= []
      end
      
      def instance_properties?
        @instance_properties && !@instance_properties.empty?
      end
    end
  end
end