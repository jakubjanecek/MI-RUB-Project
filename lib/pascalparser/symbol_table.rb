require_relative "parser_symbol"

module PascalParser

  class SymbolTable

    @@firstAvailableAddress = 0

    def initialize
      @table = {}
    end

    def find(identifier)
      if @table.key?(identifier)
        return @table[identifier]
      else
        return nil
      end
    end

    def put(identifier, symbol)
      if @table.key?(identifier)
        raise Exception, "Identifier '#{identifier}' already exists."
      end

      @table[identifier] = ParserSymbol.new(symbol.value)
    end

    # changes type of all undefined symbol in the table
    def type(type)
      @table.each { |key, value|
        if value.type == nil
          value.type = type
          value.address = @@firstAvailableAddress
        end

        increaseAvailableAddress(type)
      }
    end

    private

    def increaseAvailableAddress(type)
      case type
        when :integer
          @@firstAvailableAddress += 1
        when :float
          @@firstAvailableAddress += 2
      end
    end

  end

end