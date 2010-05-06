require 'tailor'
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
    # Checks to see if there's no spaces before a given string.  If the line
    #   being checked is a method with a question mark at the end of it, this
    #   skips checking the line.
    #
    # @param [String] string The string to check for spaces before.
    # @return [Boolean] True if there are no spaces before the string.
    def no_space_before? string
      # Get out if the check is for a '?' and that's part of a method name.
      if self.question_mark_method?
        return false
      end

      # Get out if this line is a comment line
      if self.comment_line?
        return false
      end

      # Get out if the string is within another string
      if word_is_in_string? string
        return false
      end

      # Get out if the string is within another string
      if word_is_in_regexp? string
        return false
      end

      counts = []
      spaces_before(string).each { |s| counts << s }

      result = false
      counts.each do |count|
        if count == 0
          print_problem "Line has a '#{string}' with 0 spaces before it:"
          result = true
        end
      end

      result
    end

    ##
    # Checks to see if there's no spaces after a given string.
    #
    # @param [String] string The string to check for spaces after.
    # @return [Boolean] True if there are no spaces after the string.
    def no_space_after? string
      # Get out if the check is for a '?' and that's part of a method name.
      if self.question_mark_method?
        return false
      end

      # Get out if this line is a comment line
      if self.comment_line?
        return false
      end

      # Get out if the string is within another string
      if word_is_in_string? string
        return false
      end

      # Get out if the string is within another string
      if word_is_in_regexp? string
        return false
      end

      counts = []
      spaces_after(string).each { |s| counts << s }

      result = false
      counts.each do |count|
        if count == 0
          print_problem "Line has a '#{string}' with 0 spaces after it:"
          result = true
        end
      end

      result
    end

    ##
    # Gets the number of spaces after a string.
    #
    # @param [String] string The string to check for spaces after.
    # @return [Array<Number>] An array that holds the number of spaces after
    #   every time the given string appears in a line.
    def spaces_after string
      # Get out if this line is a comment line
      if self.comment_line?
        return false
      end

      right_side_match = Regexp.new(Regexp.escape(string) + '\x20*')

      occurences = self.scan(right_side_match)

      results = []
      occurences.each do |o|
        string_spaces = o.sub(string, '')
        results << string_spaces.size
      end

      results
    end

    ##
    # Gets the number of spaces before a string.
    #
    # @param [String] string The string to check for spaces before.
    # @return [Array<Number>] An array that holds the number of spaces before
    #   every time the given string appears in a line.
    def spaces_before string
      left_side_match = Regexp.new('\x20*' + Regexp.escape(string))

      occurences = self.scan(left_side_match)
      results = []
      occurences.each do |o|
        string_spaces = o.sub(string, '')
        results << string_spaces.size
      end

      results
    end

    def question_mark_method?
      m_name = self.method_name
      #if !m_name.nil? and !m_name.scan(/\?$/).first.nil?
      #  return true
      #elsif contains_question_mark_word?
      #  return true
      #elsif self.scan(/\w+\?/)
      if self.scan(/(^\D+)\?/).empty?
        return false
      else
        return true
      end
    end

    ##
    # Checks to see if the word/chars are in a string in the line.
    #
    # @param [String] word The word/chars to see if they're in a string.
    # @return [Boolean] True if the word/chars are in a string.
    def word_is_in_string? word
      if self.scan(/(\'|\").*#{Regexp.escape(word)}+.*(\'|\")/).empty?
        return false
      else
        return true
      end
    end

    def word_is_in_regexp? word
      if self.scan(/\/.*#{Regexp.escape(word)}+(.*\/|)/).empty?
        return false
      else
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
      # list = Tailor.question_mark_words
      QUESTION_MARK_WORDS.each do |word|
        if self.include?(word)
          return true
        end
      end
      return false
    end
  end
end