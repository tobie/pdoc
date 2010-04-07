module PDoc
  module Models
    class Entity < Base
      class << Entity
        attr_accessor :repository_url
      end

      def signatures
        @signatures ||= []
      end
      
      def <=>(other)
        id.downcase <=> other.id.downcase
      end
      
      def src_code_href
        @src_code_href ||= "#{Entity.repository_url}#{@file}#LID#{@line_number}"
      end

      def signatures?
        @signatures && @signatures.empty?
      end
      
      def signature
        @signature ||= signatures.first
      end
      
      def methodized?
        !!@methodized
      end
      
      def alias
        @alias
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
