require 'pathname'

module Tailor

  # Calling modules will get the Ruby file to check, then read by line.  This
  #   class allows for checking of line-specific style by Represents a single
  #   line of a file of Ruby code.  Inherits from String so "self" can be used.
  #
  # Methods are named such that they check for bad style conditions, and return
  #   true and print the associated error message when the bad style condition
  #   is discovered in the file line.
  class FileLine < String

    LINE_LENGTH_MAX = 80

    # This passes the line of code to String (the parent) so that it can act
    #   like a standard string.
    #
    # @param [String] line_of_code Line from a Ruby file that will be checked
    #   for styling.
    # @param [Pathname] file_path Path to the file the line is in.
    # @param [Number] line_number Line number in the file that contains the
    #   line.
    # @return [String] Returns a String that includes all of the methods
    #   defined here.
    def initialize line_of_code, file_path, line_number
      super line_of_code
      @file_path = file_path
      @line_number = line_number
    end

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

    # Checks to see if the method name is using camel case.
    #
    # @return [Boolean] Returns true if the method name is camel case.
    #   Returns nil if this line doesn't contain a method definition.
    def camel_case_method?
      words = self.split(/ /)

      # If we're not dealing with a method, get outta here.
      unless self.method_line?
        return nil
      end

      # The 2nd word is the method name, so evaluate that for caps chars.
      if words[1] =~ /[A-Z]/
        print_problem "Method name uses camel case:"
        return true
      else
        return false
      end
    end

    # Checks to see if the class name is using snake case.
    #
    # @return [Boolean] Returns true if the class name is snake case.
    #   Returns nil if this line doesn't contain a class definition.
    def snake_case_class?
      words = self.split(/ /)

      # If we're dealing with a class, check for an underscore.
      unless self.class_line?
        return nil
      end

      # The 2nd word is the class name, so check that.
      if words[1] =~ /_/
        print_problem "Class name does NOT use camel case:"
        return true
      else
        return false
      end
    end

    # Checks to see if the line is the start of a method's definition.
    #
    # @return [Boolean] Returns true if the line starts with 'def'.
    def method_line?
      words = self.split(/ /)
      if words[0].eql? "def"
        return true
      else
        return false
      end
    end

    # Checks to see if the line is the start of a class's definition.
    #
    # @return [Boolean] Returns true if the line contains 'class' and the
    #   second word begins with a uppercase letter.
    def class_line?
      words = self.split(/ /)
      if words[0].eql? "class" and starts_with_uppercase?(words[1])
        return true
      else
        return false
      end
    end

    ##
    # Checks to see if the line is a regular statement (not a class, method, or
    #   comment).
    #
    # @return [Boolean] Returns true if the line is not a class, method or
    #   comment.
    def statement_line?
      if self.method_line? or self.class_line? or self.comment_line?
        return false
      else
        return true
      end
    end

    # Checks to see if the whole line is a basic comment line.  This doesn't
    #   check for trailing-line comments (@see #trailing_comment?).
    #
    # @return [Boolean] Returns true if the line begins with a pound symbol.
    def comment_line?
      if self.scan(/\s?#/).empty?
        return false
      else
        return true
      end
    end

    ##
    # Checks to see if there's whitespace at the end of the line.  Prints the
    #   number of whitespaces at the end of the line.
    #
    # @return [Boolean] Returns true if theres whitespace at the end of the
    #   line.
    def trailing_whitespace?
      count = self.trailing_whitespace_count

      if count > 0
        print_problem "Line contains #{count} trailing whitespace(s):"
        return true
      else
        return false
      end
    end

    # Checks to see if the line has trailing whitespace at the end of it. Note
    #   that this excludes empty lines that have spaces on them!
    #
    # @return [Number] Returns the number of trailing spaces at the end of the
    #   line.
    def trailing_whitespace_count
      spaces = self.scan(/(\x20+|\x09+)$/)
      if spaces.first.eql? nil
        return 0
      else
        return spaces.first.first.length
      end
    end

    ##
    # Checks to see if there's more than one one space after a comma.
    #
    # @return [Boolean] Returns true if there is more than one space after
    #   a comma.
    def more_than_one_space_after_comma?
      if self.scan(/\,\x20{2,}/).first.nil?
        return false
      elsif self.scan(/\,\x20{2,}/)
        print_problem "Line has a comma with > 1 space after it:"
        return true
      end
    end

    ##
    # Checks to see if there's no spaces after a comma and the next word.
    #
    # @return [Boolean] Returns true if there's no spaces between a comma and
    #   the next word.
    def no_space_after_comma?
      if self.scan(/\w\x20?\,\w/).first.nil?
        return false
      elsif self.scan(/\w\x20?\,\w/)
        print_problem "Line has a comma with 0 spaces after it:"
        return true
      end
    end

    ##
    # Checks to see if there's spaces before a comma.
    #
    # @return [Boolean] Returns true if there's any spaces before a comma.
    #   Returns nil if the line doesn't contain a comma.
    def space_before_comma?
      if self.scan(/\w\x20+\,/).first.nil?
        return false
      elsif self.scan(/\w\x20+\,/)
        print_problem "Line has at least one space before a comma:"
        return true
      else
        return nil
      end
    end

    ##
    # Checks to see if the line is greater than the defined max (80 chars is
    #   default).
    #
    # @return [Boolean] Returns true if the line length exceeds the allowed
    #   length.
    def too_long?
      if self.length > LINE_LENGTH_MAX
        print_problem "Line is greater than #{LINE_LENGTH_MAX} characters:"
        return true
      else
        return false
      end
    end

    #-----------------------------------------------------------------
    # Private methods
    #-----------------------------------------------------------------
    private

    ##
    # Prints the file name and line number that the problem occured on.
    #
    # @param [String] Error message to print.
    def print_problem message
      puts message
      puts "\t#{@file_path.relative_path_from(Pathname.pwd)}: #{@line_number}"
    end

    # Checks to see if a word begins with a lowercase letter.
    #
    # @param [String] word The word to check case on.
    def starts_with_lowercase? word
      if word =~ /^[a-z]/
        return true
      else
        return false
      end
    end

    # Checks to see if a word begins with an uppercase letter.
    #
    # @param [String] word The word to check case on.
    def starts_with_uppercase? word
      if word =~ /^[A-Z]/
        return true
      else
        return false
      end
    end
  end
end