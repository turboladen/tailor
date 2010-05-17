module Tailor

  # Provides methods for checking indentation problems in a FileLine.
  # 
  # 
  module Indentation

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
    # Determines the level to which the line is indented.  For Ruby, this
    #   should be 2 spaces.  Note that this treats lines that are indented an
    #   odd number of spaces as a multiple of 0.5 levels of indentation.
    # 
    # @return [Float] The level.
    def is_at_level
      if indented_spaces.eql? 0
        return 0.0
      else
        return indented_spaces.to_f / 2.0
      end
    end

    ##
    # Checks to see if the line contains a statement that should be indented.
    # 
    # @return [Boolean] True if the line contains one of the statements and
    #   does not contain 'end'.
    def indent?
      return false if self.comment_line?

      INDENT_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)

        if(self.strip =~ regexp && !(self =~ /\s+end\s*$/))
          return true
        end
      end
      return false
    end

    ##
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
      return false
    end

    ##
    # Checks to see if the line contains a statement that ends a code chunk:
    #   end, ], or }.
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
      return false
    end

    ##
    # Simply compares the level the line is at to the parameter that's passed
    #   in.  The proper level is maintained outside of this module.
    # 
    # @return [Boolean] True if level of the line doesn't match the level
    #   passed in.  Also retruns true if the line is an empty line, since that
    #   line doens't need to be checked.
    def at_improper_level? proper_level
      current_level = self.is_at_level

      if current_level == proper_level or self.empty_line?
        return false
      else
        message = "Line is at level #{current_level}, "
        message += "but should be at level #{proper_level}:"
        print_problem message
        return true
      end
    end

    def ends_with_operator?
      OPERATORS.each_pair do |op_family, op_values|
        op_values.each do |op|
          result = self.scan(/.*#{Regexp.escape(op)}\s*$/)
          unless result.empty?
            #logger = Logger.new(STDOUT)
            #logger.debug "Matched on op: #{op}"
            return true
          end
        end
      end

      return false
    end
  end
end