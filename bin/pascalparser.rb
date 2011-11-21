require_relative "../lib/pascalparser/lexer"
require_relative "../lib/pascalparser/parser"
require_relative "../lib/pascalparser/symbol_table"
require_relative "../lib/pascalparser/label_generator"

if ARGV.length == 2
  lexer = PascalParser::Lexer.new(ARGV[0])
  symbolTable = PascalParser::SymbolTable.new
  labelGenerator = PascalParser::LabelGenerator.new
  parser = PascalParser::Parser.new(lexer, symbolTable, labelGenerator)
  result = parser.parse()

  if result
    puts "Parsing successful."

    output = File.new(ARGV[1], "w")

    begin
      output.write(parser.code)
    ensure
      output.close
    end
  else
    puts "Parsing was not successful."
  end


else
  puts "USAGE: pascalparser.rb input-filename output-filename"
end
