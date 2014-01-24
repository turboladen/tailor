require_relative '../ruler'

class Tailor
  module Rulers

    # Looks for spaces after a ',' as given by +@config+.  It skips checking
    # when:
    # * the char after it is a '\n'.
    # * it's at the end of a line, followed by a trailing comment.
    class SpacesAfterCommaRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :comma, :comment, :ignored_nl, :nl
        @comma_columns = []
      end

      def comma_update(_, _, column)
        @comma_columns << column
      end

      def comment_update(token, lexed_line, _, lineno, column)
        if token =~ /\n$/
          log 'Found comment with trailing newline.'
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, _)
        check_spaces_after_comma(lexed_line, lineno)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the actual_spaces after a comma equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces after the comma.
      # @param [Fixnum] lineno Line the problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) after a comma, "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column + 1, msg,
            @options[:level])
        end
      end

      def check_spaces_after_comma(lexed_line, lineno)
        log "Commas found at: #{@comma_columns}" unless @comma_columns.empty?

        @comma_columns.each do |c|
          event_index = lexed_line.event_index(c)
          if event_index.nil?
            log 'Event index is nil.  Weird...'
            break
          end

          next_event = lexed_line.at(event_index + 1)
          if next_event.nil?
            log 'Looks like there is no next event (this is last in the line).'
            break
          end

          if next_event[1] == :on_nl || next_event[1] == :on_ignored_nl
            log 'Next event is a newline.'
            break
          end

          second_next_event = lexed_line.at(event_index + 2)
          if second_next_event.nil?
            log 'Second next event is nil.'
            next
          end

          if second_next_event[1] == :on_comment
            log 'Event + 2 is a comment.'
            next
          end

          actual_spaces = next_event[1] != :on_sp ? 0 : next_event.last.size
          measure(actual_spaces, lineno, c)
        end

        @comma_columns.clear
      end
    end
  end
end
