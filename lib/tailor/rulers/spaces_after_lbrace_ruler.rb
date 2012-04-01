require_relative '../ruler'

class Tailor
  module Rulers
    
    # Checks for spaces after a '{' as given by +@config+.  It skips checking
    # when:
    # * it's at the end of a line.
    # * the next char is a '}'
    # * it's at the end of a line, followed by a trailing comment.
    class SpacesAfterLbraceRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @lbrace_columns = []
      end
      
      def comment_update(token, lexed_line, file_text, lineno, column)
        if token =~ /\n$/
          log "Found comment with trailing newline."
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_after_lbrace(lexed_line, lineno)
      end

      def lbrace_update(lexed_line, lineno, column)
        @lbrace_columns << column
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_spaces_after_lbrace(lexed_line, lineno)
        log "lbraces found at: #{@lbrace_columns}" unless @lbrace_columns.empty?

        @lbrace_columns.each do |column|
          actual_spaces = count_spaces(lexed_line, column)

          next if actual_spaces.nil?
          
          if actual_spaces != @config
            @problems << Problem.new(:spaces_after_lbrace, lineno, column + 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end

        @lbrace_columns.clear
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

        if next_event[1] == :on_rbrace
          log "Next event is a '}'.  Looks like this is an empty Hash."
          return
        end
        
        if next_event[1] == :on_nl || next_event[1] == :on_ignored_nl
          log "Next event is a newline."
          return
        end

        second_next_event = lexed_line.at(event_index + 2)
        if second_next_event[1] == :on_comment
          log "Event + 2 is a comment."
          return
        end
        
        next_event[1] != :on_sp ? 0 : next_event.last.size
      end
    end
  end
end
