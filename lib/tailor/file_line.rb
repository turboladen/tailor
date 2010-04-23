module RubyStyleChecker

  # Calling modules will get the Ruby file to check, then read by line.  This
  #   class allows for checking of line-specific style by Represents a single
  #   line of a file of Ruby code.  Inherits from String so "self" can be used.
  class FileLine < String

    # This passes the line of code to String (the parent) so that it can act
    #   like a standard string.
    #
    # @param [String] line_of_code Line from a Ruby file that will be checked
    #   for styling.
    # @return [String] Returns a String that includes all of the methods
    #   defined here.
    def initialize line_of_code
      super line_of_code
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

    # Checks to see if the source code line is tabbed
    #
    # @return [Boolean] Returns true if the file contains a tab
    #   character before any others in that line.
    def hard_tabbed?
      result = case self
        # The line starts with a tab
        when /^\t/ then true
        # The line starts with spaces, then has a tab
        when /^\s+\t/ then true
        else false
      end
    end

    # Checks to see if the method is using camel case.
    #
    # @return [Boolean] Returns true if the method name is camel case.
    def camel_case_method?
      words = self.split(/ /)

      # If we're dealing with a method, check for uppercase chars
      if self.method?

        # The 2nd word is the method name, so evaluate that for caps chars.
        if words[1] =~ /[A-Z]/
          return true
        else
          return false
        end
      # If we're dealing with a class, check for an underscore.
      else
        return nil
      end
    end

    # Checks to see if the class is using camel case.
    #
    # @return [Boolean] Returns true if the class name is camel case.
    def camel_case_class?
      words = self.split(/ /)

      # If we're dealing with a class, check for an underscore.
      if self.class?
        if words[1] =~ /_/
          return false
        else
          return true
        end
      else
        return nil
      end
    end

    # Checks to see if the line is the start of a method's definition.
    #
    # @return [Boolean] Returns true if the line contains 'def' and the second word
    #   begins with a lowercase letter.
    def method?
      words = self.split(/ /)
      if words[0].eql? "def" and starts_with_lowercase?(words[1])
        return true
      else
        return false
      end
    end

    # Checks to see if the line is the start of a class's definition.
    #
    # @return [Boolean] Returns true if the line contains 'class' and the second word
    #   begins with a uppercase letter.
    def class?
      words = self.split(/ /)
      if words[0].eql? "class" and starts_with_uppercase?(words[1])
        return true
      else
        return false
      end
    end

    # Checks to see if the whole line is a basic comment line.  This doesn't
    #   check for trailing-line comments (@see #trailing_comment?).
    #
    # @return [Boolean] Returns true if the line begins with a pound symbol.
    def line_comment?
      if self.scan(/\s+#/).empty?
        return false
      else
        return true
      end
    end

    # Checks to see if the line has trailing whitespace at the end of it. Note that
    #   this excludes empty lines that have spaces on them!
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

    # Checks to see if a single space exists after a comma in uncomented code.  This
    #   method doesn't check if the line is a comment, so this should be done before
    #   calling this method.  @see #line_comment?.
    #
    # @return [Boolean] Returns true if only 1 space exists after a comma.
    def two_or_more_spaces_after_comma?
      if self.scan(/\w\,\s{2,}/).empty?
        return false
      else
        return true
      end
    end

    def no_space_after_comma?
      if self.scan(/\w\,\w/).empty?
        return false
      else
        return true
      end
    end

    def no_space_before_comma?
      if self.scan(/\w\s\,/)
        return true
      else
        return false
      end
    end

    # Counts the number of spaces around a comma and returns before and after values
    #   as a hash.
    #
    # @return [Hash<:before,:after>] Returns a Hash with values for :before and :after.
    def spaces_around_comma
      spaces = Hash.new

      spaces[:before] = self.scan(/(\x20+),/)
      spaces[:after] = self.scan(/,(\x20+)/)

      spaces
    end

    #-----------------------------------------------------------------
    # Private methods
    #-----------------------------------------------------------------
    private

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