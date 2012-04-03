require_relative '../ruler'

class Tailor
  module Rulers
    class MaxLineLengthRuler < Tailor::Ruler
      def ignored_nl_update(lexed_line, lineno, column)
        log "<#{self.class}> Line length: #{lexed_line.line_length}"
        measure(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the line has more characters that given at +@config+.
      #
      # @param [Fixnum] lexed_line The line to measure.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on
      def measure(lexed_line, lineno, column)
        if lexed_line.line_length > @config
          options = {
            actual_length: lexed_line.line_length,
            should_be_at: @config
          }
          @problems << Problem.new(:line_length, lineno, column, options)
        end
      end
    end
  end
end
