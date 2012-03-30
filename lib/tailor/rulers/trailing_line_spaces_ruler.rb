require_relative '../ruler'

class Tailor
  module Rulers
    class TrailingLineSpacesRuler < Tailor::Ruler
      def ignored_nl_update(lexed_line, lineno, column)
        check_line_end_for_spaces(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_line_end_for_spaces(lexed_line, lineno, column)
        log "Last event: #{lexed_line.last_non_line_feed_event}"
        log "Line ends with space: #{lexed_line.line_ends_with_sp?}"

        if lexed_line.line_ends_with_sp?
          log "Last event: #{lexed_line.last_non_line_feed_event}"
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
