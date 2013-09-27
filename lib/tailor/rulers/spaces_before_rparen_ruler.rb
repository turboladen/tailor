require_relative '../ruler'

class Tailor
  module Rulers

    # Checks for spaces before a +)+ as given by +@config+.  It skips checking
    # when:
    # * it's the first char in the line.
    # * it's directly preceded by a +(+.
    # * it's directly preceded by spaces, then a +(+.
    class SpacesBeforeRparenRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :rparen
      end

      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] the number of spaces before the rparen.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil? ||
          previous_event[1] == :on_lparen
          return nil
        end

        return 0 if previous_event[1] != :on_sp
        return nil if current_index - 2 < 0

        second_previous_event = lexed_line.at(current_index - 2)
        return nil if second_previous_event[1] == :on_lparen

        previous_event.last.size
      end

      # Checks to see if the counted spaces before an rparen equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces before the rparen.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) before a ), "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column, msg,
            @options[:level])
        end
      end

      # This has to keep track of +{+s and only follow through with the check
      # if the +{+ was an lbrace because Ripper doesn't scan the +}+ of an
      # embedded expression (embexpr_end) as such.
      #
      # @param [Tailor::LexedLine] lexed_line
      # @param [Fixnum] lineno
      # @param [Fixnum] column
      def rparen_update(lexed_line, lineno, column)
        count = count_spaces(lexed_line, column)

        if count.nil?
          log 'rparen must be at the beginning of the line.'
          return
        else
          log "Found #{count} space(s) before rparen."
        end

        measure(count, lineno, column)
      end
    end
  end
end
