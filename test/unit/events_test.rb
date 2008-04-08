require File.expand_path(File.join(File.dirname(__FILE__), "..", "test_helper"))

class EventsTest < Test::Unit::TestCase
  include PDocTestHelper
  
  def setup
    @parser = EventsParser.new
  end
  
  def test_single_event
    assert_parsed "\n * fires click"
    assert_equal %w[click],                  parse("\n * fires click").to_a
  end
  
  def test_single_namespaced_event
    assert_parsed "\n * fires element:updated"
    assert_equal %w[element:updated],        parse("\n * fires element:updated").to_a
  end
  
  def test_multiple_events
    assert_parsed "\n * fires click, element:updated"
    assert_equal %w[click element:updated],  parse("\n * fires click, element:updated").to_a
  end
end
