module PascalParser

  class LabelGenerator

    def initialize
      @counter = 0
    end

    def getLabel
      @counter += 1
      return "Label#{@counter - 1}"
    end

    def getPreviousLabel
      return "Label#{@counter - 2}"
    end

  end

end

