module Tailor

  # Provides methods for checking indentation problems in a FileLine.
  module Indentation

    ##
    # Determines the number of spaces the line is indented.
    #
    # @return [Number] Returns the number of spaces the line is indented.
    def indented_spaces
      # Find out how many spaces exist at the beginning of the line
      spaces = self.scan(/^\x20+/).first

      unless spaces.nil?
        return spaces.length
      else
        return 0
      end
    end

    ##
    # Checks to see if the source code line contains any hard tabs.
    #
    # @return [Boolean] Returns true if the file line contains hard tabs.
    #   false if the line contains only spaces.
    def hard_tabbed?
      if self.scan(/\t/).empty?
        return false
      else
        print_problem "Line contains hard tabs:"
        return true
      end
    end
  end
end