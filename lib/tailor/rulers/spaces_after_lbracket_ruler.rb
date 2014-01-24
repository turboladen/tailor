require_relative '../ruler'

class Tailor
  module Rulers

    # Detects spaces after a '[' as given by +@config+.  It skips checking
    # when:
    # * it's the last char in line.
    # * the char after it is a ']'.
    # * the char after it is space, then a '{'.
    class SpacesAfterLbracketRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :comment, :ignored_nl, :lbracket, :nl
        @lbracket_columns = []
      end

      def comment_update(token, lexed_line, _, lineno, column)
        if token =~ /\n$/
          log 'Found comment with trailing newline.'
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, _)
        check_spaces_after_lbracket(lexed_line, lineno)
      end

      def lbracket_update(_, _, column)
        @lbracket_columns << column
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the actual_spaces after an lbracket equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces after the lbracket.
      # @param [Fixnum] lineno Line the problem was found on.
      # @param [Fixnum] column Column the problem was found on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) after a [, "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column + 1, msg,
            @options[:level])
        end
      end

      def check_spaces_after_lbracket(lexed_line, lineno)
        unless @lbracket_columns.empty?
          log "lbracket found at: #{@lbracket_columns}"
        end

        @lbracket_columns.each do |column|
          actual_spaces = count_spaces(lexed_line, column)
          next if actual_spaces.nil?

          if !@do_measurement
            log 'Skipping measurement.'
          else
            measure(actual_spaces, lineno, column)
          end

          @do_measurement = true
        end

        @lbracket_columns.clear
      end

      # Counts the number of spaces after the lbracket.
      #
      # @param [LexedLine] lexed_line The LexedLine that contains the context
      #   the lbracket was found in.
      # @param [Fixnum] column Column the lbracket was found at.
      # @return [Fixnum] The number of spaces found after the lbracket.
      def count_spaces(lexed_line, column)
        event_index = lexed_line.event_index(column)

        if event_index.nil?
          log 'No lbracket in this line.  Moving on...'
          @do_measurement = false
          return
        end

        next_event = lexed_line.at(event_index + 1)
        log "Next event: #{next_event}"

        if next_event.nil?
          log 'lbracket must be at the end of the line.'
          @do_measurement = false
          return 0
        end

        [:on_nl, :on_ignored_nl].each do |event|
          if next_event[1] == event
            log "lbracket is followed by a '#{event}'.  Moving on."
            @do_measurement = false
            return 0
          end
        end

        if next_event[1] == :on_rbracket
          log 'lbracket is followed by a rbracket.  Moving on.'
          @do_measurement = false
          return 0
        end

        second_next_event = lexed_line.at(event_index + 2)
        log "Event + 2: #{second_next_event}"

        [:on_comment, :on_lbrace].each do |event|
          if second_next_event[1] == event
            log "Event + 2 is a #{event}.  Moving on."
            @do_measurement = false
            return next_event.last.size
          end
        end

        next_event[1] != :on_sp ? 0 : next_event.last.size
      end
    end
  end
end
