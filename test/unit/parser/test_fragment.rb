require "test/unit"
require "../../../lib/pdoc/parser/fragment"
require "../../../lib/pdoc/error"

class TestFragment < Test::Unit::TestCase
  
  def test_normalized_lines_of_empty_fragment
    fragment =<<EOF
    /**
    *
    *
    **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    lines = fragment.normalized_lines
    assert_equal("", lines[0])
    assert_equal("", lines[1])
    assert_equal("", lines.last)
  end
  
  def test_normalized_lines_of_basic_fragment
    fragment =<<EOF
    /**
    * foo
    *   bar
    **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    lines = fragment.normalized_lines
    assert_equal("", lines[0])
    assert_equal("foo", lines[1])
    assert_equal("  bar", lines[2])
    assert_equal("", lines.last)
  end
  
  def test_normalized_lines_of_broken_fragment
    fragment =<<EOF
    /**
    * foo
    *bar
    **/
EOF
    assert_raise PDoc::Fragment::InconsistentPrefixError do
      PDoc::Fragment.new(fragment, 0).normalized_lines
    end
  end
  
  def test_empty_prefix
    fragment =<<EOF
/**
foo
  bar
**/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    assert_equal("", fragment.prefix)
  end
  
  def test_whitespace_prefix
    fragment =<<EOF
    /**
  foo
    bar
  **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    assert_equal("  ", fragment.prefix)
  end

  def test_mixed_prefix
    fragment =<<EOF
/**
 * foo
 *   bar
 **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    assert_equal(" * ", fragment.prefix)
  end 
end