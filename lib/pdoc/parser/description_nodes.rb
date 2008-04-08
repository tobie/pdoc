module Description
  class Text < Treetop::Runtime::SyntaxNode
    include Enumerable
    def each
      elements.map { |e| e.to_s }.each { |tag| yield tag }
    end
    
    def join(sep = "\n")
      to_a.join(sep).strip
    end
    
    def to_s
      join
    end
    
    def inspect
      text = truncate(15).gsub(/\n/, " ").strip.inspect
      "#<#{self.class} #{text}>"
    end
    
    def truncate(num = 30)
      to_s.length < num ? to_s : to_s.slice(0..num) << "..."
    end
  end
end