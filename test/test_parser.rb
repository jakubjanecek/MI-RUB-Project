require_relative "../lib/pascalparser/lexer"
require_relative "../lib/pascalparser/symbol_table"
require_relative "../lib/pascalparser/label_generator"
require_relative "../lib/pascalparser/parser"
require "test/unit"

class TestParser < Test::Unit::TestCase

  def test_parser1
    lexer = PascalParser::Lexer.new("Program1.pas")
    parser = PascalParser::Parser.new(lexer, PascalParser::SymbolTable.new, PascalParser::LabelGenerator.new)

    result = parser.parse
    assert_equal(true, result)

    code = parser.code
    expected = <<END
.class public Program1
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
getstatic java/lang/System/out Ljava/io/PrintStream;
ldc 42
invokevirtual java/io/PrintStream/println(I)V
return
.end method
END
    assert_equal(expected, code)
  end

  def test_parser2
    lexer = PascalParser::Lexer.new("Program9.pas")
    parser = PascalParser::Parser.new(lexer, PascalParser::SymbolTable.new, PascalParser::LabelGenerator.new)

    result = parser.parse
    assert_equal(true, result)

    code = parser.code
    expected = <<END
.class public Program9
.super java/lang/Object
.method public static main([Ljava/lang/String;)V
.limit stack 100
.limit locals 100
ldc 1
istore 1
ldc 1
istore 0
goto Label0
Label1:
iinc 0 1
Label0:
iload 0
ldc 5
if_icmpgt Label2
iload 1
ldc 3
imul
istore 1
goto Label1
Label2:
getstatic java/lang/System/out Ljava/io/PrintStream;
iload 1
invokevirtual java/io/PrintStream/println(I)V
ldc 1
istore 2
ldc 5
istore 0
goto Label3
Label4:
iinc 0 -1
Label3:
iload 0
ldc 1
if_icmplt Label5
iload 2
ldc 3
imul
istore 2
goto Label4
Label5:
getstatic java/lang/System/out Ljava/io/PrintStream;
iload 2
invokevirtual java/io/PrintStream/println(I)V
iload 1
istore 0
goto Label6
Label7:
iinc 0 1
Label6:
iload 0
iload 2
if_icmpgt Label8
getstatic java/lang/System/out Ljava/io/PrintStream;
ldc 99
invokevirtual java/io/PrintStream/println(I)V
goto Label7
Label8:
ldc2_w 0.5
dstore 4
ldc2_w 3.4
dstore 6
iload 1
ldc 10
irem
istore 0
goto Label9
Label10:
iinc 0 1
Label9:
iload 0
iload 1
ldc 10
idiv
if_icmpgt Label11
dload 4
dload 4
dload 6
dmul
dadd
dstore 4
dload 6
ldc2_w 0.1
dadd
dstore 6
goto Label10
Label11:
getstatic java/lang/System/out Ljava/io/PrintStream;
dload 4
invokevirtual java/io/PrintStream/println(D)V
getstatic java/lang/System/out Ljava/io/PrintStream;
dload 6
invokevirtual java/io/PrintStream/println(D)V
return
.end method
END
    assert_equal(expected, code)
  end

end