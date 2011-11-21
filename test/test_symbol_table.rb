require_relative "../lib/pascalparser/symbol_table"
require_relative "../lib/pascalparser/lexer_symbol"
require "test/unit"

class TestSymbolTable < Test::Unit::TestCase

  def test_put_and_find
    table = PascalParser::SymbolTable.new
    symbol = PascalParser::LexerSymbol.new(:ident, "value")
    table.put("id01", symbol)
    found = table.find("id01")
    assert_equal(symbol.value, found.identifier)
  end

  def test_put_unique
    table = PascalParser::SymbolTable.new
    symbol = PascalParser::LexerSymbol.new(:ident, "value")
    table.put("id01", symbol)
    assert_raises(Exception) {
      table.put("id01", symbol)
    }
  end

  def test_type_and_address
    table = PascalParser::SymbolTable.new
    symbol = PascalParser::LexerSymbol.new(:ident, "value")
    table.put("id01", symbol)
    table.type(:integer)
    found = table.find("id01")
    assert_equal(:integer, found.type)
    assert_equal(0, found.address)
    assert_equal("value", found.identifier)

    symbol = PascalParser::LexerSymbol.new(:ident, "value")
    table.put("id02", symbol)
    table.type(:float)
    found = table.find("id02")
    assert_equal(:float, found.type)
    assert_equal(1, found.address)
    assert_equal("value", found.identifier)

    symbol = PascalParser::LexerSymbol.new(:ident, "value")
    table.put("id03", symbol)
    table.type(:integer)
    found = table.find("id03")
    assert_equal(3, found.address)
  end

end