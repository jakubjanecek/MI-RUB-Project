require_relative "../lib/pascalparser/label_generator"
require "test/unit"

class TestLabelGenerator < Test::Unit::TestCase

  def test_generator
    generator = PascalParser::LabelGenerator.new

    label1 = generator.getLabel
    label2 = generator.getLabel
    previous1 = generator.getPreviousLabel
    label3 = generator.getLabel
    previous2 = generator.getPreviousLabel


    assert_equal("Label0", label1)
    assert_equal("Label1", label2)
    assert_equal(label1, previous1)
    assert_equal("Label2", label3)
    assert_equal(label2, previous2)
  end

end