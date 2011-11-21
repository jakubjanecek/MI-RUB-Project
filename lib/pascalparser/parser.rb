require_relative "symbol_table"

module PascalParser

  # Implements a syntactical analyzer (parser) for a subset of Pascal programming language.
  # It is a top-down recursive descent parser.
  #
  # Pascal
  # * variable declarations, only types integer and real
  # * mathematical expressions with multiplication, division (and modulo), addition and subtraction
  # * conditional expressions with equals, not equals, less than, greater than and equals variants
  # * if-then-else construct
  # * for cycle with to and downto counters
  # * while cycle
  # * writeln command for standard output
  class Parser

    attr_reader :code

    # Initializes the parser.
    # It needs to be given fresh instances of lexical analyzer, symbol table and label generator.
    def initialize(lexer, symbolTable, labelGenerator)
      @lexer = lexer
      @symbolTable = symbolTable
      @labelGenerator = labelGenerator
      @code = ""
    end

    # Does the parsing.
    # Returns true or false.
    # Program code can be retrieved from Parser#code when finished.
    def parse
      @lexer.open

      readSymbol

      begin
        # start symbol
        program()
        return true
      rescue Exception => err
        puts "Error at line #{@lexer.lineNumber}, character #{@lexer.characterPosition}:\n\t#{err.to_s}"
        return false
      ensure
        @lexer.close
      end
    end

    private

    def readSymbol
      @symbol = @lexer.nextSymbol
    end

    def compare(symb)
      if @symbol.kind == symb
        returnSymbol = @symbol
        readSymbol
        return returnSymbol
      else
        raise Exception, "Expected '#{symb}' but got '#{@symbol.kind}'."
      end
    end

    def instruction(instr)
      @code += "#{instr}\n"
    end

    def binaryOperation(operation, left, right)
      case left
        when :integer
          case right
            when :integer
              instruction("i#{operation}")
            when :float
              raise Exception, "Cannot convert left operand."
          end
        when :float
          case right
            when :integer
              instruction("i2d")
          end
          instruction("d#{operation}")
      end
    end

    def decideType(left, right)
      if left == :float || right == :float
        return :float
      end

      return :integer
    end

    def program
      compare(:program)
      programName = compare(:ident)
      compare(:semi)

      instruction(".class public #{programName.value}");
      instruction(".super java/lang/Object");
      instruction(".method public static main([Ljava/lang/String;)V");
      instruction(".limit stack 100");
      instruction(".limit locals 100");

      block()
      compare(:period)

      instruction("return");
      instruction(".end method");
    end

    def block
      case @symbol.kind
        when :var, :begin
          variableDeclarations()
          compoundCommand()
        else
          raise Exception, "Expected variable declarations or program block."
      end
    end

    def variableDeclarations()
      case @symbol.kind
        when :var
          readSymbol
          variableDeclaration()
          compare(:semi)
          restOfVariableDeclarations()
      end
    end

    def variableDeclaration()
      listOfIdentifiers()
      compare(:colon)
      declarationOfType()
    end

    def listOfIdentifiers()
      identifier = compare(:ident)
      @symbolTable.put(identifier.value, identifier)
      restOfListOfIdentifiers()
    end

    def restOfListOfIdentifiers()
      case @symbol.kind
        when :comma
          readSymbol
          listOfIdentifiers()
      end
    end

    def declarationOfType
      case @symbol.kind
        when :integer
          @symbolTable.type(@symbol.kind)
          readSymbol
        when :float
          @symbolTable.type(@symbol.kind)
          readSymbol
        else
          raise Exception, "Expected type integer or real, not '#{@symbol}'."
      end
    end

    def restOfVariableDeclarations()
      case @symbol.kind
        when :ident
          variableDeclaration()
          compare(:semi)
          restOfVariableDeclarations()
      end
    end

    def compoundCommand
      compare(:begin)
      commandSequence()
      compare(:end)
    end

    def commandSequence
      case @symbol.kind
        when :ident, :begin, :if, :while, :writeln, :semi, :end
          command()
          restOfCommandSequence()
        else
          raise Exception, "Expected a sequence of commands, not #{@symbol.kind}."
      end
    end

    def command()
      case @symbol.kind
        when :ident
          assignment()
        when :begin
          compoundCommand()
        when :if
          ifCommand()
        when :while
          whileCommand()
        when :for
          forCommand()
        when :writeln
          writelnCommand()
        when :semi, :else, :end
          # empty
        else
          raise Exception, "Expected a command, not #{@symbol.kind}."
      end
    end

    def assignment()
      identifier = compare(:ident)
      symbol = @symbolTable.find(identifier.value)
      compare(:assign)
      expressionType = expression()
      if symbol != nil
        if symbol.type == expressionType
          case expressionType
            when :integer
              instruction("istore #{symbol.address}")
            when :float
              instruction("dstore #{symbol.address}")
          end
        else
          raise Exception, "Different variable type. Expected '#{symbol.type}', not #{expressionType}."
        end
      else
        raise Exception, "Variable '#{identifier.value}' was not declared."
      end
    end

    def expression
      case @symbol.kind
        when :plus, :minus, :ident, :integer, :float, :lpar
          sign = sign()
          termType = term()

          if sign == :negative
            case termType
              when :integer
                instruction("ineg")
              when :float
                instruction("dneg")
            end
          end
        else
          raise Exception, "Expected an expression, not #{@symbol}."
      end

      return restOfExpression(termType)
    end

    def sign
      case @symbol.kind
        when :plus
          readSymbol
          return :positive
        when :minus
          readSymbol
          return :negative
      end
    end

    def term()
      case @symbol.kind
        when :ident, :integer, :float, :lpar
          factorType = factor()
          return restOfTerm(factorType)
        else
          raise Exception, "Expected a term, not #{@symbol}."
      end
    end

    def factor()
      returnType = nil

      case @symbol.kind
        when :ident
          symb = @symbolTable.find(@symbol.value)
          if symb != nil
            case symb.type
              when :integer
                instruction("iload #{symb.address}")
              when :float
                instruction("dload #{symb.address}")
            end

            readSymbol
            returnType = symb.type
          else
            raise Exception, "Variable '#{@symbol.value}' not declared"
          end
        when :integer
          symb = compare(:integer)
          instruction("ldc #{symb.value}")
          returnType = :integer
        when :float
          symb = compare(:float)
          instruction("ldc2_w #{symb.value}")
          returnType = :float
        when :lpar
          readSymbol
          expressionType = expression()
          compare(:rpar)

          returnType = expressionType
        else
          raise Exception, "Expected a factor, not #{@symbol}."
      end

      return returnType
    end

    def restOfTerm(typeOfLeft)
      case @symbol.kind
        when :asterisk, :slash, :div, :mod
          operator = multiplicativeOperator()
          typeOfRight = factor()

          case operator
            when :asterisk
              operation = "mul"
            when :slash, :div
              operation = "div"
            when :mod
              operation = "rem"
          end

          binaryOperation(operation, typeOfLeft, typeOfRight)
          return restOfTerm(decideType(typeOfLeft, typeOfRight))
        when :plus, :minus, :eq, :ne, :lt, :gt, :lte, :gte, :semi, :rpar, :do, :if, :then, :else, :to, :downto, :writeln, :for, :ident
          # empty
          return typeOfLeft
        else
          raise Exception, "Expected rest of the term, not #{@symbol}."
      end
    end

    def multiplicativeOperator
      case @symbol.kind
        when :asterisk
          readSymbol
          return :asterisk
        when :slash
          readSymbol
          return :slash
        when :div
          readSymbol
          return :div
        when :mod
          readSymbol
          return :mod
        else
          raise Exception, "Expected a multiplicative operator, not #{@symbol}."
      end
    end

    def restOfExpression(typeOfLeft)
      case @symbol.kind
        when :plus, :minus
          operator = additiveOperator()
          typeOfRight = term()
          case operator
            when :plus
              operation = "add"
            when :minus
              operation = "sub"
          end

          binaryOperation(operation, typeOfLeft, typeOfRight)
          return restOfExpression(decideType(typeOfLeft, typeOfRight))
        else
          return typeOfLeft
      end
    end

    def additiveOperator
      case @symbol.kind
        when :plus
          readSymbol
          return :plus
        when :minus
          readSymbol
          return :minus
        else
          raise Exception, "Expected a additive operator, not #{@symbol}."
      end
    end

    def restOfCommandSequence()
      case @symbol.kind
        when :semi
          readSymbol
          command()
          restOfCommandSequence()
      end
    end


    def ifCommand
      compare(:if)
      conditionLabel = @labelGenerator.getLabel
      condition(conditionLabel)
      compare(:then)
      command()
      elsePart()
    end

    def condition(label)
      case @symbol.kind
        when :plus, :minus, :ident, :integer, :float, :lpar
          typeOfLeft = expression()
          operator = relationOperator()
          typeOfRight = expression()

          if typeOfLeft == :integer && typeOfRight == :float
            raise Exception, "Cannot convert left operand."
          end

          additionalOperations = []
          case operator
            when :eq
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmpne"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "ifne"
                end
              end
            when :ne
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmpeq"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "ifeq"
                end
              end
            when :lt
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmpge"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "ifge"
                end
              end

            when :gt
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmple"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "ifle"
                end
              end
            when :lte
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmpgt"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "ifgt"
                end
              end
            when :gte
              if typeOfLeft == :integer && typeOfRight == :integer
                operation = "if_icmplt"
              else
                if typeOfLeft == :float || typeOfRight == :float
                  if typeOfLeft == :integer
                    additionalOperations.push("i2d")
                  end
                  additionalOperations.push("dcmpg")
                  operation = "iflt"
                end
              end
          end

          if !additionalOperations.empty?
            additionalOperations.each { |op| instruction("#{op}") }
          end
          instruction("#{operation} #{label}")
        else
          raise Exception, "Expected a condition, not #{@symbol}."
      end
    end

    def relationOperator
      operator = @symbol.kind
      case @symbol.kind
        when :eq
          readSymbol
        when :ne
          readSymbol
        when :lt
          readSymbol
        when :gt
          readSymbol
        when :lte
          readSymbol
        when :gte
          readSymbol
        else
          raise Exception, "Expected a relation operator, not #{@symbol}."
      end

      return operator
    end

    def elsePart
      case @symbol.kind
        when :else
          elseLabel = @labelGenerator.getLabel

          readSymbol

          instruction("goto #{elseLabel}");
          instruction("#{@labelGenerator.getPreviousLabel}:");

          command()

          instruction("#{elseLabel}:");
        else
          @labelGenerator.getLabel # useless generation but needed fo the code generator to work
          instruction("#{@labelGenerator.getPreviousLabel}:");
      end
    end

    def whileCommand
      compare(:while)

      cycleLabel = @labelGenerator.getLabel
      conditionLabel = @labelGenerator.getLabel
      instruction("#{cycleLabel}:")
      condition(conditionLabel)
      compare(:do)
      command()

      instruction("goto #{cycleLabel}")
      instruction("#{conditionLabel}:")
    end

    def forCommand
      compare(:for)
      identifier = compare(:ident)
      symbol = @symbolTable.find(identifier.value)
      compare(:assign)
      expressionType = expression()

      if symbol != nil
        if symbol.type == expressionType
          if expressionType == :integer
            instruction("istore #{symbol.address}")
          else
            instruction("dstore #{symbol.address}")
          end
        else
          raise Exception, "Different variable type. Expected '#{symbol.type}', not '#{expressionType}'."
        end
      else
        raise Exception, "Variable '#{identifier.value}' not declared."
      end

      label1 = @labelGenerator.getLabel;
      label2 = @labelGenerator.getLabel;
      label3 = @labelGenerator.getLabel;
      instruction("goto #{label1}");
      instruction("#{label2}:");

      direction = forPart()

      case direction
        when :up
          instruction("iinc #{symbol.address} 1");
        when :down
          instruction("iinc #{symbol.address} -1");
      end

      instruction("#{label1}:");
      instruction("iload #{symbol.address}");

      expression()

      case direction
        when :up
          instruction("if_icmpgt #{label3}")
        when :down
          instruction("if_icmplt #{label3}")
      end

      compare(:do)
      command()

      instruction("goto #{label2}");
      instruction("#{label3}:");
    end

    def forPart
      case @symbol.kind
        when :to
          readSymbol
          return :up
        when :downto
          readSymbol
          return :down
        else
          raise Exception, "Expected keyword 'to' or 'downto', not #{@symbol}."
      end
    end

    def writelnCommand
      compare(:writeln)
      instruction("getstatic java/lang/System/out Ljava/io/PrintStream;");
      compare(:lpar)
      expressionType = expression()
      compare(:rpar)
      case expressionType
        when :integer
          instruction("invokevirtual java/io/PrintStream/println(I)V")
        when :float
          instruction("invokevirtual java/io/PrintStream/println(D)V")
      end
    end

  end

end
