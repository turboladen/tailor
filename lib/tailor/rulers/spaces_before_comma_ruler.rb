require_relative '../ruler'

class Tailor
  module Rulers
    
    # Checks for spaces before a ',' as given by +@config+.
    class SpacesBeforeCommaRuler < Tailor::Ruler
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

      def check_spaces_before_comma(lexed_line, lineno)
        @comma_columns.each do |c|
          event_index = lexed_line.event_index(c)
          if event_index.nil?
            log "Event index is nil.  Weird..."
            next
          end

          previous_event = lexed_line.at(event_index - 1)
          actual_spaces = if previous_event[1] != :on_sp
            0
          else
            previous_event.last.size
          end

          if actual_spaces != @config
            @problems << Problem.new(:spaces_before_comma, lineno, c - 1,
              { actual_spaces: actual_spaces, should_have: @config })
          end
        end

        @comma_columns.clear
      end

      def ignored_nl_update(lexed_line, lineno, column)
        check_spaces_before_comma(lexed_line, lineno)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end
    end
  end
end
