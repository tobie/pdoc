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
      
      def path_to(foo)
        '/some/path' # Not tested here, although it should
      end
    end
  end
  
  def test_auto_link
    html = run_helper(:auto_link, 'Element')
    assert_match %r(<a.*?>Element</a>), html, 'Simple namespace not linked'
    # Ellipsis typographical conversion: '...' -> '…'
    doc = parse_doc('Element#foo() -> Element...')
    html = run_helper(:auto_link, doc, doc.to_a.last.returns)
    assert_equal 'Element…', html, 'Ellipsis not converted'
    # Per-item processing of alternatives (w/ or w/o '...'/'…')
    doc = parse_doc('Element.fakeMethod( ) -> Element | Array')
    html = run_helper(:auto_link, doc, doc.to_a.last.returns)
    assert_match %r(<a.*?>Element</a>), html, 'Namespace in alternative not linked'
    assert_no_match %r(<a.*?>Array</a>), html, 'Generic type in alternative linked'
    doc = parse_doc('Element.fakeMethod( ) -> [Element...] | Array')
    html = run_helper(:auto_link, doc, doc.to_a.last.returns)
    assert_match %r(<a.*?>Element</a>…), html, 'Ellipsis-bearing namespace in alternative not linked'
    # Per-item processing of arrays (w/ or w/o '...'/'…')
    doc = parse_doc('Element#foo() -> [Element, String]')
    html = run_helper(:auto_link, doc, doc.to_a.last.returns)
    assert_match %r(<a.*?>Element</a>), html, 'Namespace in array not linked'
    doc = parse_doc('Element#foo() -> [Element..., String]')
    html = run_helper(:auto_link, doc, doc.to_a.last.returns)
    assert_match %r(<a.*?>Element</a>…), html, 'Ellipsis-bearing namespace in array not linked'
  end
  
  def test_methodized_synopsis
    html = run_helper(:method_synopsis, 'Element.down(@element[,selector][,index=0]) -> Element')
    assert_equal 2, html.scan('&rArr;').size, 'Missing signature (1 instead of 2)'
    assert html.include?('Element.down(element[,selector][,index=0])'), 'Missing static signature'
    assert html.include?('Element#down([selector][,index=0])'), 'Missing instance signature'
    
    html = run_helper(:method_synopsis, %(
    Element.up(@element[, expression[, index = 0]]) -> Element
    Element.up(@element[, index = 0]) -> Element
    ))
    
    assert_equal 3, html.scan('&rArr;').size, 'Missing signature(s) (should have 3)'
    assert html.include?('Element.up(element[, expression[, index = 0]])'), 'Missing static signature'
    assert html.include?('Element#up([expression[, index = 0]])'), 'Missing instance signature 1'
    assert html.include?('Element#up([index = 0])'), 'Missing instance signature 2'
  end
  
  def test_synopsis
    # Static signature
    html = run_helper(:method_synopsis, 'Ajax.getTransport( ) -> XMLHttpRequest | ActiveXObject')
    assert_equal 1, html.scan('&rArr;').size, 'Incorrect signature count'
    assert html.include?('Ajax.getTransport()'), 'Missing static signature'
    # Instance signature
    html = run_helper(:method_synopsis, 'Ajax.Request#request(url) -> undefined')
    assert_equal 1, html.scan('&rArr;').size, 'Incorrect signature count'
    assert html.include?('Ajax.Request#request(url)'), 'Missing instance signature'
    # Multiple signatures
    html = run_helper(:method_synopsis, %(
    $(element) -> Element
    $(element...) -> [Element...]
    ))
    assert_equal 2, html.scan('&rArr;').size, 'Incorrect signature count'
    assert html.include?('$(element)'), 'Missing single-argument signature'
    assert html.include?('$(element...)'), 'Missing vararg signature'
  end
  
  def parse_doc(source)
    src = %(
/** section: dom
 * class Element
 **/

/**
#{source.strip.map { |line| " * #{line.lstrip}" }}
 **/
    )
  PDoc::Parser.new(src).parse
  end
  
  def run_helper(method, root, arg = nil)
    root = parse_doc(root) if root.is_a?(String)
    @helper.root = root
    @helper.send(method, arg || root.to_a.last)
  end
end
