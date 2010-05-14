module Tailor

  # Provides methods for checking indentation problems in a FileLine.
  # 
  # 
  module Indentation

    INDENT_SIZE = 2

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
    # Determines how much the next line should be indented/outdented.  If it
    #   finds one of the expressions, it should return either 1.0 or -1.0; if
    #   it doesn't it returns 0.0.
    # 
    # @return [Float] The level to which the next line should be indented/outdented
    #   by.
    def indent_type
      if self.empty_line?
        return :empty
      end

      if end?
        return :end
      end

      if self.comment_line?
        return :same
      end


      return :same
    end

    def indent?
      return false if self.comment_line?

      INDENT_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)

        #unless result.empty? and self.scan(/\s+end\s*$/)
        #if(!result.empty? && !(self =~ /\s+end\s*$/))
        if(self.strip =~ regexp && !(self =~ /\s+end\s*$/))
          #return 1.0
          return true
        end
      end
      return false
    end

    def outdent?
      return false if self.comment_line?

      OUTDENT_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)
        
        # If it does contain an expression, set the proper level to be out 1.0.
        unless result.empty?
          #return -1.0
          return true
        end
      end
      return false
    end

    def contains_end?
      return false if self.comment_line?

      END_EXPRESSIONS.each do |regexp|
        result = self.strip.scan(regexp)
        
        # If it does contain an expression, set the proper level to be out 1.0.
        unless result.empty?
          @logger.debug "Found match: #{regexp}"
          return true
        end
      end
      return false
    end

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
  end
end