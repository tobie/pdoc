module EbnfArguments
  class Argument < Treetop::Runtime::SyntaxNode
    def name
      text_value
    end
    
    def optional?
      false
    end
    
    def default_value
      nil
    end
  end

  class OptionalArgument < Treetop::Runtime::SyntaxNode
    def name
      required_argument.text_value
    end
    
    def optional?
      true
    end
    
    def default_value
      if default.empty?
        nil
      else
        value = default.value.text_value.strip
        value.empty? ? nil : value
      end
    end
  end
  
  class Arguments < Treetop::Runtime::SyntaxNode
    def to_a
      [argument].concat(args.elements.map {|e| e.argument})
    end
  end
end
