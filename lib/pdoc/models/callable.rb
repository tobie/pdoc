module PDoc
  module Models
    module Callable
      def arguments
        @arguments ||= []
      end
      
      def arguments?
        @arguments && !@arguments.empty?
      end
    end
  end
end