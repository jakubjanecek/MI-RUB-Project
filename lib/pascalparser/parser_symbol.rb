module PascalParser

  # Represents a parser symbol with attributes identifier, type and address.
  class ParserSymbol

    attr_reader :identifier
    attr_accessor :type, :address

    def initialize(identifier)
      @identifier = identifier
      @type = nil
      @address = nil
    end

    def to_s
      "#{@identifier}:#{@type.to_s}@#{@address}"
    end

  end

end