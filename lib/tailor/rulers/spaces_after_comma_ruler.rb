require_relative '../ruler'

class Tailor
  module Rulers
    
    # Looks for spaces after a ',' as given by +@config+.  It skips checking
    # when:
    # * the char after it is a '\n'.
    # * it's at the end of a line that has a trailing comment.
    class SpacesAfterCommaRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @comma_columns = []
      end

      def comma_update(text_line, lineno, column)
        @comma_columns << column
      end

      def comment_update(token, lexed_line, file_text, lineno, column)
        if token =~ /\n$/
          log "Found comment with trailing newline."
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_after_comma(lexed_line, lineno)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_spaces_after_comma(lexed_line, lineno)
        log "Commas found at: #{@comma_columns}"

        @comma_columns.each do |c|
          event_index = lexed_line.event_index(c)
          if event_index.nil?
            log "Event index is nil.  Weird..."
            break
          end

          next_event = lexed_line.at(event_index + 1)
          if next_event.nil?
            log "Looks like there is no next event (this is last in the line)."
            break
          end

          if next_event[1] == :on_nl || next_event[1] == :on_ignored_nl
            log "Next event is a newline."
            break
          end

          second_next_event = lexed_line.at(event_index + 2)
          if second_next_event[1] == :on_comment
            log "Event + 2 is a comment."
            next
          end

          actual_spaces = next_event[1] != :on_sp ? 0 : next_event.last.size

          if actual_spaces != @config
            @problems << Problem.new(:spaces_after_comma, lineno, c + 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end

        @comma_columns.clear
      end
    end
  end
end
