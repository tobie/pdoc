module PDoc
  module Generators
    module Html
      class Template < ERB
        
        def initialize(file_name = "layout.erb", templates_directory = nil)
          @file_name = file_name
          @templates_directory = templates_directory
          super(IO.read(file_path), nil, '%')
        end
        
        private
          def file_path
            @file_name << '.erb' unless @file_name =~ /\.erb$/
            path = File.join(@templates_directory, @file_name.split("/"))
            File.expand_path(path, DIR)
          end
      end
    end
  end
end
