require File.expand_path(File.join(File.dirname(__FILE__), "..", "parser_test_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. .. templates html helpers]))

class HtmlHelpersTest < Test::Unit::TestCase
  include PDocTestHelper
  # include EbnfExpression
  
  def setup
    @helper = Object.new
    class << @helper
      attr_accessor :root
      include PDoc::Generators::Html::Helpers::BaseHelper
      include PDoc::Generators::Html::Helpers::LinkHelper
      include PDoc::Generators::Html::Helpers::CodeHelper
    end
  end
  
  def test_auto_link
    # FIXME tdd: auto_link testing: regular + tdd's extensions (array, sequences, etc.)
  end
  
  def test_methodized_synopsis
    syn = run_helper(:method_synopsis, parse_doc('Element.down(@element[,selector][,index=0]) -> Element'))
    assert_equal 2, syn.scan('&rArr;').size, 'Missing signature (1 instead of 2)'
    assert syn.include?('Element.down(element[,selector][,index=0])'), 'Missing static signature'
    assert syn.include?('Element#down([selector][,index=0])'), 'Missing instance signature'
    
    syn = run_helper(:method_synopsis, parse_doc(%(
    Element.up(@element[, expression[, index = 0]]) -> Element
    Element.up(@element[, index = 0]) -> Element
    )))
    
    assert_equal 3, syn.scan('&rArr;').size, 'Missing signature(s) (should have 3)'
    assert syn.include?('Element.up(element[, expression[, index = 0]])'), 'Missing static signature'
    assert syn.include?('Element#up([expression[, index = 0]])'), 'Missing instance signature 1'
    assert syn.include?('Element#up([index = 0])'), 'Missing instance signature 2'
  end
  
  def test_synopsis
    # FIXME tdd: non-methodized synopsis testing
    ebnf  = ''
    ebnf2 = ''
  end
  
  def parse_doc(source)
    PDoc::Parser.new("/**\n#{source.strip.map { |line| " * #{line.lstrip}" }}\n **/").parse
  end
  
  def run_helper(method, root)
    @helper.root = root
    @helper.send(method, root.first)
  end
end
