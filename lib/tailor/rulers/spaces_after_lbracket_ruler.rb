require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesAfterLBracketRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @lbracket_columns = []
      end
      
      def comment_update(token, lexed_line, file_text, lineno, column)
        if token =~ /\n$/
          log "Found comment with trailing newline."
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_after_lbracket(lexed_line, lineno)
      end

      def lbracket_update(lexed_line, lineno, column)
        @lbracket_columns << column
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_spaces_after_lbracket(lexed_line, lineno)
       log "lbrackets found at: #{@lbracket_columns}"

        @lbracket_columns.each do |column|
          actual_spaces = count_spaces(lexed_line, column)

          next if actual_spaces.nil?
          
          if actual_spaces != @config
            @problems << Problem.new(:spaces_after_lbracket, lineno, column + 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end

        @lbracket_columns.clear
      end
      
      def count_spaces(lexed_line, column)
        event_index = lexed_line.event_index(column)
        if event_index.nil?
          log "Event index is nil.  Weird..."
          return
        end

        next_event = lexed_line.at(event_index + 1)
        if next_event.nil?
          log "Looks like there is no next event (this is last in the line)."
          return
        end

        if next_event[1] == :on_rbracket
          log "Next event is a ']'.  Looks like this is an empty Array."
          return
        end
        
        if next_event[1] == :on_nl || next_event[1] == :on_ignored_nl
          log "Next event is a newline.  Moving on."
          return
        end

        second_next_event = lexed_line.at(event_index + 2)
        log "Event + 2: #{second_next_event}"
        
        if second_next_event[1] == :on_comment
          log "Event + 2 is a comment.  Moving on."
          return
        end
        
        if second_next_event[1] == :on_lbrace
          log "Event + 2 is a {.  Moving on."
          return
        end
        
        next_event[1] != :on_sp ? 0 : next_event.last.size
      end
    end
  end
end
