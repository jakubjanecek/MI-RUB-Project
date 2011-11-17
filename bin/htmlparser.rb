require_relative "../lib/htmlparser/lexer"
require_relative "../lib/htmlparser/parser"

if ARGV.length == 1
  lexer = HTMLParser::Lexer.new(ARGV[0])
  parser = HTMLParser::Parser.new(lexer)
  parser.parse(ARGV[0])
else
  puts "USAGE: htmlparser.rb input-filename"
end
