HTML_DIR = File.expand_path(File.join(File.dirname(__FILE__), "html"))

# Prefer RDiscount because BlueCloth is slow and has problems with Ruby 1.9.
require 'rdiscount'
require File.join(HTML_DIR, "helpers")
require File.join(HTML_DIR, "template")
require File.join(HTML_DIR, "page")
require File.join(HTML_DIR, "website")

