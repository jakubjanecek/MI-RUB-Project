module HTMLParser

  class Lexer

    def initialize(filename)
      @filename = filename
    end

    def open
      @input = File.new(@filename, "r")
      readCharacter
    end

    def nextSymbol
      while @kind == :delimiter
        readCharacter
      end

      case @kind
        when :special
          @symbol = processSpecial
        when :letter
          @symbol = processLetter
        when :eof
          # end of input
          @symbol = :eoi
      end

      return @symbol
    end

    def close
      @input.close
    end


    private

    def readCharacter
      begin
        @character = @input.readchar
        @kind = case
                  when char.match /[<>"=\/]/
                    :special
                  when char.match /\s/
                    :delimiter
                  else
                    :letter
                end
      rescue EOFError
        @kind = :eof
      end
    end

    def processSpecial
      return case @character
               when "<"
                 :lt
               when ">"
                 :gt
               when "\""
                 :quote
               when "="
                 :equals
               when "/"
                 :slash
             end
    end

    def processLetter
      return case @character

             end
    end

  end

end