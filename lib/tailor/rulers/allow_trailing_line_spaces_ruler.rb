require_relative '../ruler'

class Tailor
  module Rulers
    class AllowTrailingLineSpacesRuler < Tailor::Ruler
      def ignored_nl_update(lexed_line, lineno, column)
        log "Last event: #{lexed_line.last_non_line_feed_event}"
        log "Line ends with space: #{lexed_line.line_ends_with_sp?}"

        measure(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the line contains trailing spaces.
      #
      # @param [LexedLine] lexed_line The line to check for trailing spaces.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(lexed_line, lineno, column)
        if lexed_line.line_ends_with_sp?
          options = {
            actual_trailing_spaces:
              lexed_line.last_non_line_feed_event.last.size
          }
          @problems << Problem.new(:trailing_spaces, lineno, column, options)
        end
      end
    end
  end
end
