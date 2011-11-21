require_relative "lexer_symbol"

module PascalParser

  # Implements a lexical analyzer for a subset of Pascal programming language.
  #
  # Pascal
  # * variable declarations, only types integer and real
  # * mathematical expressions with multiplication, division (and modulo), addition and subtraction
  # * conditional expressions with equals, not equals, less than, greater than and equals variants
  # * if-then-else construct
  # * for cycle with to and downto counters
  # * while cycle
  # * writeln command for standard output
  class Lexer

    attr_reader :keywords, :lineNumber, :characterPosition

    def initialize(filename)
      @filename = filename
      @keywords = {
          "program" => :program,
          "var" => :var,
          "integer" => :integer,
          "real" => :float,
          "begin" => :begin,
          "end" => :end,
          "div" => :div,
          "mod" => :mod,
          "and" => :and,
          "or" => :or,
          "if" => :if,
          "then" => :then,
          "else" => :else,
          "while" => :while,
          "do" => :do,
          "for" => :for,
          "to" => :to,
          "downto" => :downto,
          "writeln" => :writeln
      }

      @lineNumber = 1
      @characterPosition = 0
    end

    # Initializes the lexer.
    # <b>Needs to be called before Lexer#nextSymbol is called for the first time.</b>
    def open
      @input = File.new(@filename, "r")
      readCharacter
    end

    # Returns the next LexerSymbol from the input.
    def nextSymbol
      skipWhitespace

      case @kind
        when :letter
          return processLetter
        when :digit
          return processNumber
        when :special
          return processSpecial
        when :eof
          # end of input
          return LexerSymbol.new(:eoi)
        else
          raise Exception
      end
    end

    # Closes the lexer.
    # <b>Needs to be called when finished working with the lexer.</b>
    def close
      @input.close
    end


    private

    def readCharacter
      begin
        @character = @input.readchar
        @characterPosition += 1
        case
          when @character.match(/[a-zA-Z]/)
            @kind = :letter
          when @character.match(/\d/)
            @kind = :digit
          when @character.match(/[\(\),:;=\+\-\*\/<>\.]/)
            @kind = :special
          when @character.match(/\s/)
            @kind = :delimiter

            if @character.match(/\n/)
              @lineNumber += 1
              @characterPosition = 1
            end
          else
            @kind = :any
        end
      rescue EOFError
        @kind = :eof
      end
    end

    def skipWhitespace
      while @kind == :delimiter
        readCharacter
      end
    end

    def processLetter
      ident = @character
      readCharacter
      while (@kind == :letter || @kind == :digit) && (@kind != :special || @kind != :delimiter || @kind != :eof)
        ident += @character
        readCharacter
      end

      return processKeyword(ident)
    end

    def processKeyword(ident)
      if @keywords.key?(ident.downcase)
        return LexerSymbol.new(@keywords[ident.downcase])
      else
        return LexerSymbol.new(:ident, ident)
      end
    end

    def processNumber
      number = @character.to_i
      readCharacter
      while (@kind == :digit || @kind == :special) && (@kind != :delimiter && @kind != :eof)
        if @kind == :special && @character == "."
          floatPart = processFloat
          return LexerSymbol.new(:float, number + floatPart)
        end

        if @kind == :digit
          number = (10 * number) + @character.to_i
          readCharacter
        else
          break
        end
      end

      return LexerSymbol.new(:integer, number)
    end

    def processFloat
      number = 0
      decimalDigits = 0
      readCharacter
      while @kind == :digit && (@kind != :special || @kind != :delimiter || @kind != :eof)
        number = (10 * number) + @character.to_i
        decimalDigits += 1
        readCharacter
      end

      conversion = 0.1
      # i = <1, decimalDigits)
      for i in 1...decimalDigits
        conversion *= 0.1
      end

      return (number * conversion)
    end

    def processSpecial
      case @character
        when "("
          symb = :lpar
        when ")"
          symb = :rpar
        when ","
          symb = :comma
        when ":"
          readCharacter
          if @character == "="
            symb = :assign
          else
            symb = :colon
          end
        when ";"
          symb = :semi
        when "+"
          symb = :plus
        when "-"
          symb = :minus
        when "*"
          symb = :asterisk
        when "/"
          symb = :slash
        when "="
          symb = :eq
        when "<"
          readCharacter
          case @character
            when "="
              symb = :lte
            when ">"
              symb = :ne
            else
              symb = :lt
          end
        when ">"
          readCharacter
          case @character
            when "="
              symb = :gte
            else
              symb = :gt
          end
        when "."
          symb = :period
        else
          raise Exception
      end

      readCharacter

      return LexerSymbol.new(symb)
    end

  end

end