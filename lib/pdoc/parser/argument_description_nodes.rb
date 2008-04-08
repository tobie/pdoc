module ArgumentDescription
  class ArgumentDescription < Treetop::Runtime::SyntaxNode
    def name
      argument_name.text_value
    end
    
    def types
      if arg_types.empty?
        []
      else
        args = arg_types.elements.last
        [args.argument_type.text_value].concat(args.more.elements.map{ |e| e.argument_type.text_value })
      end
    end
    
    def description
      argument_description_text.to_s
    end
  end
end