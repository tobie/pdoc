module PDoc
  module Models
    class Entity < Base
      class << Entity
        attr_accessor :src_code_href
      end
      attr_accessor :alias
      
      def signatures
        @signatures ||= []
      end
      
      def <=>(other)
        id.downcase <=> other.id.downcase
      end
      
      def src_code_href
        proc = Entity.src_code_href
        @src_code_href ||= proc ? proc.call(@file, @line_number) : nil
      end

      def signatures?
        @signatures && !@signatures.empty?
      end
      
      def signature
        @signature ||= signatures.first
      end
      
      def methodized?
        !!@methodized
      end
      
      def alias?
        !!@alias
      end
      
      # returns an array of aliases
      def aliases
        @aliases ||= []
      end
      
      def aliases?
        @aliases && !@aliases.empty?
      end
    end
  end
end
