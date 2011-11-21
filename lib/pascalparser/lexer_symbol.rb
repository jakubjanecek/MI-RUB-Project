module PascalParser

  # Represents a lexical symbol with attributes kind (kind of character) and value (character).
  class LexerSymbol

    attr_reader :kind, :value

    def initialize(kind, value = nil)
      @kind = kind
      @value = value
    end

    def to_s
      if @value.nil?
        @kind.to_s
      else
        "#{@value} (#{@kind.to_s})"
      end
    end

  end

end