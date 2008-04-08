DIR = File.dirname(__FILE__)
OUTPUT_DIR = File.expand_path(File.join(DIR, "..", "output"))
TEMPLATES_DIR = File.expand_path(File.join(DIR, "..", "templates"))
PARSER_DIR = File.expand_path(File.join(DIR, "pdoc", "parser"))
VENDOR_DIR = File.expand_path(File.join(DIR, "..", "vendor"))

[DIR, VENDOR_DIR, PARSER_DIR, OUTPUT_DIR, TEMPLATES_DIR].each do |c|
  $:.unshift File.expand_path(c)
end

require 'erb' 
require File.expand_path(File.join(DIR, "pdoc", "generators"))
require File.expand_path(File.join(DIR, "pdoc", "parser"))
