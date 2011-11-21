require_relative "parser_symbol"

module PascalParser

  # Implements a simple parser's symbol table for storage and retrieval of program identifiers.
  # It also provides type information (integer or real) and memory address assignment.
  class SymbolTable

    def initialize
      @table = {}
      @firstAvailableAddress = 0
    end

    # Returns ParserSymbol for given identifier if it is in the table or nil.
    def find(identifier)
      if @table.key?(identifier)
        return @table[identifier]
      else
        return nil
      end
    end

    # Puts a new ParserSymbol for given identifier into the table if it is not present already.
    def put(identifier, symbol)
      if @table.key?(identifier)
        raise Exception, "Identifier '#{identifier}' already exists."
      end

      @table[identifier] = ParserSymbol.new(symbol.value)
    end

    # Assigns the type to all _untyped_ symbols in the table.
    # It also assigns an address to them.
    def type(type)
      @table.each { |key, value|
        if value.type == nil
          value.type = type
          value.address = @firstAvailableAddress

          increaseAvailableAddress(type)
        end
      }
    end

    private

    # Increases the next available address based on the last variable's type.
    def increaseAvailableAddress(type)
      case type
        when :integer
          @firstAvailableAddress += 1
        when :float
          @firstAvailableAddress += 2
      end
    end

  end

end