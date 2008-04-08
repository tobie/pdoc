module Tags
  class Tags < Treetop::Runtime::SyntaxNode
    include Enumerable
    
    def include?(tag_name)
      any? {|tag| tag.name == tag_name }
    end
    
    def each
      [tag].concat(more.elements.map { |e| e.tag }).each { |tag| yield tag }
    end
  end
end