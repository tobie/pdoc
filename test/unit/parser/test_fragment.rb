require "test/unit"
require "../../../lib/pdoc/parser/fragment"
require "../../../lib/pdoc/error"

class TestFragment < Test::Unit::TestCase
  
  def test_normalize_empty_fragment
    fragment =<<EOF
    /**
    *
    *
    **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    lines = fragment.normalize
    assert_equal("", lines[0])
    assert_equal("", lines[1])
    assert_equal("", lines.last)
  end
  
  def test_normalize_basic_fragment
    fragment =<<EOF
    /**
    * foo
    *   bar
    **/
EOF
    fragment = PDoc::Fragment.new(fragment, 0)
    lines = fragment.normalize
    assert_equal("", lines[0])
    assert_equal("foo", lines[1])
    assert_equal("  bar", lines[2])
    assert_equal("", lines.last)
  end
  
  def test_normalize_broken_fragment
    fragment =<<EOF
    /**
    * foo
    *bar
    **/
EOF
    assert_raise PDoc::Fragment::InconsistentPrefixError do
      PDoc::Fragment.new(fragment, 0).normalize
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