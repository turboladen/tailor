require_relative '../ruler'

class Tailor
  module Rulers
    class MaxLineLengthRuler < Tailor::Ruler
      def ignored_nl_update(lexed_line, lineno, column)
        check_line_length(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_line_length(lexed_line, lineno, column)
        log "<#{self.class}> Line length: #{lexed_line.line_length}"

        if lexed_line.line_length > @config
          options = {
            actual_length: lexed_line.line_length,
            should_be_at: @config
          }
          @problems << Problem.new(:line_length, lineno, column, options)
          log "ERROR: Line length.  #{@problems.last[:message]}"
        end
      end
    end
  end
end
