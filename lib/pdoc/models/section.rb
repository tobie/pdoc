module PDoc
  module Models
    class Section < Base
      include Container
      
      def attach_to_parent(parent)
        parent.sections << self
      end
      
      def name
        @name ||= @id.sub(' section', '')
      end
    end
  end
end
