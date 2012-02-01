require_relative 'spacing'

module Tailor

  # Provides methods for checking indentation problems in a FileLine.
  module Indentation
    include Tailor::Spacing

    INDENT_SIZE = 2
    HARD_TAB_SIZE = 4

    INDENT_EXPRESSIONS = [
      /^class\b/,
      /^module\b/,
      /^def\b/,
      /(=\s*|^)if\b/,
      /(=\s*|^)until\b/,
      /(=\s*|^)for\b/,
      /(=\s*|^)unless\b/,
      /(=\s*|^)while\b/,
      /(=\s*|^)begin\b/,
      /(=\s*|^)case\b/,
      /\bthen\b/,
#      /^rescue\b/,
      /\bdo\b/,
#      /^else\b/,
#      /^elsif\b/,
#      /^ensure\b/,
#      /\bwhen\b/,
      /\{[^\}]*$/,
      /\[[^\]]*$/
      ]

    OUTDENT_EXPRESSIONS = [
      /^rescue\b/,
      /^ensure\b/,
      /^elsif\b/,
#      /^end\b/,
      /^else\b/,
      /\bwhen\b/,
#      /^[^\{]*\}/,    # matches and end } when no { appears
#      /^[^\[]*\]/
      ]

    END_EXPRESSIONS = [
      /^end\b/,
      /^[^\{]*\}/,    # matches and end } when no { appears
      /^[^\[]*\]/     # matches and end ] when no [ appears
      ]

    # Determines the number of spaces the line is indented.
    #
    # @return [Number] Returns the number of spaces the line is indented.
    def indented_spaces
      # Find out how many spaces exist at the beginning of the line
      spaces = self.scan(/^\x20+/).first

      unless spaces.nil?
        return spaces.length
      end

      0
    end

    # Determines the level to which the line is indented.  For Ruby, this
    # should be 2 spaces.  Note that this treats lines that are indented an
    # odd number of spaces as a multiple of 0.5 levels of indentation.
    #
    # @return [Float] The level.
    def is_at_level
      spaces = indented_spaces

      if spaces.eql? 0
        return 0.0
      end

      spaces.to_f / 2.0
    end

    # Checks to see if the line contains a statement that should be indented.
    #
    # @return [Boolean] True if the line contains one of the statements and
    # does not contain 'end'.
    def indent?
      return false if self.comment_line?

      INDENT_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)

        if(self.strip =~ regexp && !(self =~ /\s+end\s*$/))
          return true
        end
      end

      false
    end

    # Checks to see if the line contains a statement that should be outdented.
    #
    # @return [Boolean] True if the line contains one of the statements.
    def outdent?
      return false if self.comment_line?

      OUTDENT_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)

        # If it does contain an expression, set the proper level to be out 1.0.
        unless result.empty?
          return true
        end
      end

      false
    end

    # Checks to see if the line contains a statement that ends a code chunk:
    # end, ], or }.
    #
    # @return [Boolean] True if the line contains one of the statements.
    def contains_end?
      return false if self.comment_line?

      END_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)

        # If it does contain an expression, set the proper level to be out 1.0.
        unless result.empty?
          #@logger.debug "Found match: #{regexp}"
          return true
        end
      end

      false
    end

    # Simply compares the level the line is at to the parameter that's passed
    # in.  The proper level is maintained outside of this module.
    #
    # @return [Boolean] True if level of the line doesn't match the level
    # passed in.  Also returns true if the line is an empty line, since that
    # line doesn't need to be checked.
    def at_improper_level? proper_level
      current_level = self.is_at_level

      if current_level == proper_level or self.empty_line?
        return false
      end

      message = "Line is at level #{current_level}, "
      message += "but should be at level #{proper_level}:"
      @line_problem_count += 1
      print_problem message

      true
    end

    def ends_with_operator?
      if self.comment_line?
        return false
      end

      result = false

      OPERATORS.each_pair do |op_family, op_values|
        op_values.each do |op|
          match = self.scan(/.*#{Regexp.escape(op)}\s*$/)

          next if op == '?' and self.question_mark_method?

          unless match.empty?
            logger = Logger.new(STDOUT)
            logger.debug "Matched on op: #{op}"
            result = true
          end
        end
      end

      result
    end

    def ends_with_comma?
      if self.comment_line?
        return false
      end

      unless self.scan(/.*,\s*$/).empty?
        puts "Ends with comma."
        return true
      end

      false
    end

    def ends_with_backslash?
      if self.comment_line?
        return false
      end

      unless self.scan(/.*\\\s*$/).empty?
        puts "Ends with backslash."
        return true
      end

      false
    end

    def unclosed_parenthesis?
      if self.comment_line?
        return false
      end

      unless self.scan(/\([^\)]*(?!=\))\s*$/).empty?
        puts "Ends with unclosed parenthesis."
        return true
      end

      false
    end

    def only_closed_parenthesis?
      if self.comment_line?
        return false
      end

      unless self.scan(/^\s*[^\(](\w*|\s*)\)/).empty?
        return true
      end

      false
    end

    def multi_line_statement?
      if self.comment_line?
        return false
      end

      if self.ends_with_operator? or self.ends_with_comma? or
        self.ends_with_backslash? or self.unclosed_parenthesis?
        return true
      end

      false
    end
  end
end
