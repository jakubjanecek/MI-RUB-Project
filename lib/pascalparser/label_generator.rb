module PascalParser

  # Implements a simple generator of labels.
  class LabelGenerator

    def initialize
      @counter = 0
    end

    # Returns a new unique (for given instance of generator) label.
    def getLabel
      @counter += 1
      return "Label#{@counter - 1}"
    end

    # Returns a second to last generated label.
    def getPreviousLabel
      return "Label#{@counter - 2}"
    end

  end

end

