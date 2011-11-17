require_relative "../lib/rectangles/calculator"
require_relative "../lib/rectangles/rectangle"
require "test/unit"

class TestCalculator < Test::Unit::TestCase

  def test_calculator
    r1 = Rectangles::Rectangle.new(5, 5, 10)
    r2 = Rectangles::Rectangle.new(-20, -20, 5)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(false, c.intersect?)
    assert_equal(false, c.touch?)
    assert_equal(0, c.union_area)

    r1 = Rectangles::Rectangle.new(5, 5, 10)
    r2 = Rectangles::Rectangle.new(15, 15, 10)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(false, c.intersect?)
    assert_equal(true, c.touch?)
    assert_equal(0, c.union_area)

    r1 = Rectangles::Rectangle.new(5, 5, 10)
    r2 = Rectangles::Rectangle.new(5, 15, 10)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(false, c.intersect?)
    assert_equal(true, c.touch?)
    assert_equal(0, c.union_area)

    r1 = Rectangles::Rectangle.new(5, 5, 10)
    r2 = Rectangles::Rectangle.new(-5, 5, 10)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(false, c.intersect?)
    assert_equal(true, c.touch?)
    assert_equal(0, c.union_area)

    r1 = Rectangles::Rectangle.new(-10e20, 3e-2, 5.23)
    r2 = Rectangles::Rectangle.new(+3e100, -1, 4.345643225)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(false, c.intersect?)
    assert_equal(false, c.touch?)
    assert_equal(0, c.union_area)

    r1 = Rectangles::Rectangle.new(0, 0, 4)
    r2 = Rectangles::Rectangle.new(2, 2, 2)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(true, c.intersect?)
    assert_equal(false, c.touch?)
    assert_equal(19, c.union_area)

    r1 = Rectangles::Rectangle.new(0.000, 0.000e-3, 4.0)
    r2 = Rectangles::Rectangle.new(-2, -2e0, 2.0e+0)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(true, c.intersect?)
    assert_equal(false, c.touch?)
    assert_equal(19, c.union_area)

    r1 = Rectangles::Rectangle.new(5, 5, 10)
    r2 = Rectangles::Rectangle.new(5.0, 5.0, 10.0)
    c = Rectangles::Calculator.new(r1, r2)
    assert_equal(true, c.intersect?)
    assert_equal(false, c.touch?)
    assert_equal(100, c.union_area)
  end

end