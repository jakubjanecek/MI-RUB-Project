require_relative "../lib/pascalparser/lexer"
require "test/unit"

class TestLexer < Test::Unit::TestCase

  def test_lexer
    lexer = PascalParser::Lexer.new("Program1.pas")

    lexer.open

    assert_equal(:program, lexer.nextSymbol.kind)

    s = lexer.nextSymbol
    assert_equal(:ident, s.kind)
    assert_equal("Program1", s.value)

    assert_equal(:semi, lexer.nextSymbol.kind)
    assert_equal(:begin, lexer.nextSymbol.kind)
    assert_equal(:writeln, lexer.nextSymbol.kind)
    assert_equal(:lpar, lexer.nextSymbol.kind)

    s = lexer.nextSymbol
    assert_equal(:integer, s.kind)
    assert_equal(42, s.value)

    assert_equal(:rpar, lexer.nextSymbol.kind)
    assert_equal(:semi, lexer.nextSymbol.kind)
    assert_equal(:end, lexer.nextSymbol.kind)

    lexer.close
  end

end