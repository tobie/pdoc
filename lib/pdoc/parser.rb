require 'rubygems'
require 'treetop'

FILE_NAMES = %w[basic tags argument_description description ebnf_arguments ebnf_expression section_content documentation]

FILE_NAMES.each { |file_name| require "#{file_name}_nodes" }

%w[ebnf_javascript events].concat(FILE_NAMES).each do |file_name|
  Treetop.load File.expand_path(File.join(PARSER_DIR, "treetop_files", file_name))
end

module PDoc
  class Parser
    def initialize(string)
      @string = string
      @parser = DocumentationParser.new
    end
    
    # Parses the preprocessed string. Returns an instance
    # of Documentation::Doc
    def parse
      @parser.parse(pre_process)
    end
    
    # Preprocess the string before parsing.
    # Converts "\r\n" to "\n" and avoids edge case
    # by wrapping the string in line breaks.
    def pre_process
      "\n" << @string.gsub(/\r\n/, "\n") << "\n"
    end
  end
end