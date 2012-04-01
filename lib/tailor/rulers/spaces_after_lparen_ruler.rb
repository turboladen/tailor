require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesAfterLparenRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @lparen_columns = []
      end
      
      def comment_update(token, lexed_line, file_text, lineno, column)
        if token =~ /\n$/
          log "Found comment with trailing newline."
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_after_lparen(lexed_line, lineno)
      end

      def lparen_update(lineno, column)
        @lparen_columns << column
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      def check_spaces_after_lparen(lexed_line, lineno)
        unless @lparen_columns.empty?
         log "lparens found at: #{@lparen_columns}"
        end

        @lparen_columns.each do |column|
          actual_spaces = count_spaces(lexed_line, column)
          next if actual_spaces.nil?
          
          if actual_spaces != @config
            @problems << Problem.new(:spaces_after_lparen, lineno, column + 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end

        @lparen_columns.clear
      end
      
      def count_spaces(lexed_line, column)
        event_index = lexed_line.event_index(column)
        if event_index.nil?
          log "Event index is nil.  Weird..."
          return
        end

        next_event = lexed_line.at(event_index + 1)
        log "Next event: #{next_event}"
        
        if next_event.nil?
          log "Looks like there is no next event (this is last in the line)."
          return
        end

        [:on_rparen, :on_nl, :on_ignored_nl].each do |event|
          if next_event[1] == event
            log "Next event is a '#{event}'.  Moving on."
            return
          end
        end

        second_next_event = lexed_line.at(event_index + 2)
        log "Event + 2: #{second_next_event}"
        
        [:on_comment, :on_lbrace, :on_lparen].each do |event|
          if second_next_event[1] == event
            log "Event + 2 is a #{event}.  Moving on."
            return
          end
        end
        
        next_event[1] != :on_sp ? 0 : next_event.last.size
      end
    end
  end
end
