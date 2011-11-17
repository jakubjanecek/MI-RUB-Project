require_relative "../lib/rectangles/rectangle"
require "test/unit"

class TestRectangle < Test::Unit::TestCase

  def test_area
    length = 10
    r1 = Rectangles::Rectangle.new(0, 0, length)
    assert_equal(length * length, r1.area)

    length = 9.9
    r2 = Rectangles::Rectangle.new(0, 0, length)
    assert_equal(length * length, r2.area)
  end

  # ltrb = left top right bottom
  def test_ltrb
    x = 0
    y = 0
    length = 10
    r1 = Rectangles::Rectangle.new(x, y, length)
    assert_equal(x - (length / 2), r1.left)
    assert_equal(y + (length / 2), r1.top)
    assert_equal(x + (length / 2), r1.right)
    assert_equal(y - (length / 2), r1.bottom)

    x = 3
    y = 4
    length = 5
    r2 = Rectangles::Rectangle.new(x, y, length)
    assert_equal(x - (length / 2), r2.left)
    assert_equal(y + (length / 2), r2.top)
    assert_equal(x + (length / 2), r2.right)
    assert_equal(y - (length / 2), r2.bottom)

    x = -10
    y = 3
    length = 5
    r3 = Rectangles::Rectangle.new(x, y, length)
    assert_equal(x - (length / 2), r3.left)
    assert_equal(y + (length / 2), r3.top)
    assert_equal(x + (length / 2), r3.right)
    assert_equal(y - (length / 2), r3.bottom)
  end

end