DIR = File.dirname(__FILE__)
OUTPUT_DIR = File.expand_path(File.join(DIR, "..", "output"))
TEMPLATES_DIR = File.expand_path(File.join(DIR, "..", "templates"))
PARSER_DIR = File.expand_path(File.join(DIR, "pdoc", "parser"))
VENDOR_DIR = File.expand_path(File.join(DIR, "..", "vendor"))

[DIR, VENDOR_DIR, PARSER_DIR, OUTPUT_DIR, TEMPLATES_DIR].each do |c|
  $:.unshift File.expand_path(c)
end

require 'erb'
require 'fileutils'

require File.expand_path(File.join(DIR, "pdoc", "runner"))
require File.expand_path(File.join(DIR, "pdoc", "generators"))
require File.expand_path(File.join(DIR, "pdoc", "parser"))

module PDoc
  def self.copy_templates(template_type, destination)
    dir = File.expand_path(destination)
    raise "File already exists: #{destination}" if File.exist?(dir)
    FileUtils.cp_r("#{TEMPLATES_DIR}/#{template_type}", dir)
  end
end
