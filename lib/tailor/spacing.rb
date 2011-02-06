require 'tailor'
require 'tailor/file_line'

module Tailor

  # This module provides methods for detecting spacing problems on a single
  # line in a file.  The real intent here is to mix in to the FileLine class.
  module Spacing
    # TODO: Add skipping of comment lines.
    SPACING_CONDITIONS = {
      :more_than_one_space_after_comma => [
        /\,\x20{2,}(\w|'|"|:).*((?:(?!#\s*)).)*$/,
        "[Spacing]  Line has a comma with > 1 space after it"
        ],
      :no_space_after_comma => [
        /\,\x20{0}\S/,
        "[Spacing]  Line has a comma with 0 spaces after it"
        ],
      :space_before_comma => [
        /\S\x20+\,/,
        "[Spacing]  Line has at least one space before a comma"
        ],
      :space_after_open_parenthesis => [
        /\(\x20+/,
        "[Spacing]  Line has a '(' with spaces after it"
        ],
      :space_before_closed_parenthesis => [
        /^\s*[^#]\w+.*\x20+\)/,
        "[Spacing]  Line has a ')' with spaces before it"
        ],
      :space_around_open_bracket => [
        /^\s*[^#](\w+\x20+\[|.*\[\x20+)/,
        "[Spacing]  Line has a '[' with at least 1 space around it"
        ],
      :space_before_closed_bracket => [
        /^\s*[^#]\w+.*\x20+\]/,
        "[Spacing]  Line has a ']' with spaces before it"
        ],
      :hard_tabbed => [
        /\t+/,
        "[Spacing]  Line contains hard tabs"
        ],
      :trailing_whitespace => [
        /(\x20+|\x09+)$/,
        #"[Spacing]  Line contains #{trailing_whitespace_count} " +
        "[Spacing]  Line contains trailing whitespaces"
        ],
      :no_space_around_open_curly_brace => [
        /^\s*((?:(?!def).)*)(=|\w)\x20{0}\{|\{\x20{0}(\||:|"|')/,
        "[Spacing]  Line contains 0 spaces on at least one side of a '{'"
        ],
      :no_space_before_closed_curly_brace => [
        /^\s*((?:(?!#\{).)*)(?:(?!\{)\S)\x20{0}\}/,
        "[Spacing]  Line contains 0 spaces before a '}'"
        ],
      :more_than_one_space_around_open_curly_brace => [
        /\w\x20{2,}\{|\{\x20{2,}\|/,
        "[Spacing]  Line contains >1 spaces around a '{'"
        ],
      :more_than_one_space_before_closed_curly_brace => [
        /\w\x20{2,}\}\s*$/,
        "[Spacing]  Line contains >1 spaces before a '}'"
        ],
      :not_one_space_around_ternary_colon => [
        /^.*\?.*\w((\x20{0}|\x20{2,}):(?!:)|[^:|\[]:(\x20{0}|\x20{2,})\w)/,
        "[Spacing]  Line contains ternary ':' with not 1 space around it"
        ]
      }

    # Detect spacing problems around all predefined bad cases.
    #
    # @return [Number] The number of problems discovered during detection.
    def spacing_problems
      problem_count = 0

      # Disregard text in regexps
      self.gsub!(/\/.*?\//, "''")
      self.gsub!(/'.*?'/, "''")

      SPACING_CONDITIONS.each_pair do |condition, values|
        unless self.scan(values.first).empty?
          problem_count += 1
          @line_problem_count += 1
          print_problem values[1]
        end
      end

      problem_count
    end

    # Checks to see if there's whitespace at the end of the line.  Prints the
    # number of whitespaces at the end of the line.
    #
    # @return [Boolean] Returns true if there's whitespace at the end of the
    # line.
=begin
    def trailing_whitespace?
      count = self.trailing_whitespace_count

      if count > 0
        @line_problem_count += 1
        print_problem "Line contains #{count} trailing whitespace(s):"
        return true
      end

      return false
    end
=end
    # Checks to see if the line has trailing whitespace at the end of it. Note
    # that this excludes empty lines that have spaces on them!
    #
    # @return [Number] Returns the number of trailing spaces at the end of the
    # line.
    def trailing_whitespace_count
      spaces = self.scan(/(\x20+|\x09+)$/)

      if spaces.first.eql? nil
        return 0
      end

      spaces.first.first.length
    end
    module_function :trailing_whitespace_count

    # Checks to see if there's no spaces before a given string.  If the line
    # being checked is a method with a question mark at the end of it, this
    # skips checking the line.
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

      counts = []
      spaces_before(string).each { |s| counts << s }

      result = false
      counts.each do |count|
        if count == 0
          @line_problem_count += 1
          print_problem "Line has a '#{string}' with 0 spaces before it:"
          result = true
        end
      end

      result
    end

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
          @line_problem_count += 1
          print_problem "Line has a '#{string}' with 0 spaces after it:"
          result = true
        end
      end

      result
    end

    # Gets the number of spaces after a string.
    #
    # @param [String] string The string to check for spaces after.
    # @return [Array<Number>] An array that holds the number of spaces after
    # every time the given string appears in a line.
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

    # Checks to see if the line contains a method name with a ?.
    #
    # @return [Boolean] True if the line contains a method line include?.
    def question_mark_method?
      if self.scan(/[a-zA-Z|_]\w*\?/).empty?
        return false
      end

      true
    end
  end
end