require 'file_line'

module Tailor

  # This module provides methods for detecting spacing problems on a single
  # line in a file.  The real intent here is to mix in to the FileLine class.
  module Spacing

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

    ##
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
    # Checks to see if there's spaces after an open parenthesis.
    #
    # @return [Boolean] Returns true if there's spaces after an open
    #   parenthesis.
    def space_after_open_parenthesis?
      if self.scan(/\(\x20+/).first.nil?
        return false
      elsif self.scan(/\(\x20+/)
        print_problem "Line has an open parenthesis with spaces after it:"
        return true
      end
    end

    ##
    # Checks to see if there's spaces after an open bracket.
    #
    # @return [Boolean] Returns true if there's spaces after an open
    #   bracket.
    def space_after_open_bracket?
      if self.scan(/\[\x20+/).first.nil?
        return false
      elsif self.scan(/\[\x20+/)
        print_problem "Line has an open bracket with spaces after it:"
        return true
      end
    end

    ##
    # Checks to see if there's spaces before a closed parenthesis.
    # 
    # @return [Boolean] Returns true if there's spaces before a closed
    #   parenthesis.
    def space_before_closed_parenthesis?
      if self.scan(/\x20+\)/).first.nil?
        return false
      elsif self.scan(/\x20+\)/)
        print_problem "Line has a closed parenthesis with spaces before it:"
        return true
      end
    end

    ##
    # Checks to see if there's spaces before a closed brackets.
    # 
    # @return [Boolean] Returns true if there's spaces before a closed
    #   bracket.
    def space_before_closed_bracket?
      if self.scan(/\x20+\]/).first.nil?
        return false
      elsif self.scan(/\x20+\]/)
        print_problem "Line has a closed bracket with spaces before it:"
        return true
      end
    end

    ##
    # Checks to see if there's no spaces around operators.
    # 
    # @return [Boolean] Returns true if there's more or less than one
    #   space around the defined list of operators.
    def no_space_around? word
      if no_space_on_left_side?(word) or no_space_on_right_side?(word)
        print_problem "Line has a '#{word}' with 0 spaces around it:"
        return true
      elsif !no_space_on_left_side?(word) and !no_space_on_right_side?(word)
        return false
      end
    end

    ##
    # Checks to see if there's no spaces on the right side of the given word.
    # 
    # @return [Boolean] Returns true if there's no space on the right side of
    #   the given word.
    def no_space_on_right_side? word
      right_side_match = Regexp.new(Regexp.escape(word) + '\x20{0}\w')
      
      if self.scan(right_side_match).first.nil?
        return false
      elsif !self.scan(right_side_match).first.nil?
        return true
      end
    end

    ##
    # Checks to see if there's no spaces on the left side of the given word.
    # 
    # @return [Boolean] Returns true if there's no space on the left side of
    #   the given word.
    def no_space_on_left_side? word
      left_side_match = Regexp.new('\w\x20{0}' + Regexp.escape(word))

      # Get out if the check is for a '?' and that's part of a method name.
      m_name = self.method_name
      if !self.method_name.nil? and !m_name.scan(/\?$/).first.nil?
        return false
      end

      # Get out if the word is supposed to have a question mark at the end
      # of it.
      if self.contains_question_mark_word?
        return false
      end

      if self.scan(left_side_match).first.nil?
        return false
      elsif !self.scan(left_side_match).first.nil?
        return true
      end
    end

    ##
    # Checks to see if the word given to it is one that is OK to contain a
    #   question mark at the end of it.
    #
    # @return [Boolean] Returns true if the word is in the list of words with
    #   question marks at the end of it.
    def contains_question_mark_word?

      # Check to see if the FileLine contains any of these methods
      list = question_mark_words
      list.each do |word|
        if self.include?(word)
          return true
        end
      end
      return false
    end

    ##
    # Returns a list of all known methods that end with a question mark.
    # 
    # @return [Array<String>] An array of method names with question marks
    #   at the end of them.
    def question_mark_words
      list = []

      methods.grep(/\?$/).each { |m| list << m.to_s }
      protected_methods.grep(/\?$/).each { |m| list << m.to_s }
      private_methods.grep(/\?$/).each { |m| list << m.to_s }
      Module.instance_methods.grep(/\?$/).each { |m| list << m.to_s }

      list.sort
    end
  end
end