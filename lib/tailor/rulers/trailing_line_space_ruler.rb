require_relative '../ruler'

class Tailor
  module Rulers
    class TrailingLineSpaceRuler < Tailor::Ruler
      def ignored_nl_update(lexed_line, lineno, column)
        check_line_end_for_spaces(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_line_end_for_spaces(lexed_line, lineno, column)
        log "<#{self.class}> last event: #{lexed_line.last_non_line_feed_event}"
        log "<#{self.class}> line ends with space: #{lexed_line.line_ends_with_sp?}"

        if lexed_line.line_ends_with_sp?
          log "<#{self.class}> Last event: #{lexed_line.last_non_line_feed_event}"
          options = {
            actual_trailing_spaces: lexed_line.last_non_line_feed_event.last.size
          }
          @problems << Problem.new(:trailing_spaces, lineno, column, options)
        end
      end
    end
  end
end
