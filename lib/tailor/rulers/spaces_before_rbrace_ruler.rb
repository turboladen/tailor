require_relative '../ruler'

class Tailor
  module Rulers
    # Checks for spaces before a +}+ as given by +@config+.  It skips checking
    # when:
    # * it's the first char in the line.
    # * it's the first char in the line, preceded by spaces.
    # * it's directly preceded by a +{+.
    class SpacesBeforeRbraceRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :embexpr_beg, :lbrace, :rbrace
        @lbrace_nesting = []
        @embexpr_nesting = []
      end

      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] the number of spaces before the rbrace.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil?
          log 'rbrace is at the beginning of the line.'
          @do_measurement = false
          return 0
        end

        if previous_event[1] == :on_lbrace
          log "rbrace comes after a '{'"
          @do_measurement = false
          return 0
        end

        return 0 if previous_event[1] != :on_sp

        if current_index - 2 < 0
          log 'rbrace is at the beginning of an indented line.  Moving on.'
          @do_measurement = false
          return previous_event.last.size
        end

        previous_event.last.size
      end

      def embexpr_beg_update(_, _, _)
        if RUBY_VERSION < '2.0.0'
          @lbrace_nesting << :embexpr_beg
        end
      end

      def lbrace_update(_, _, _)
        @lbrace_nesting << :lbrace
      end

      # Checks to see if the number of spaces before an rbrace equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces after the rbrace.
      # @param [Fixnum] lineno Line the problem was found on.
      # @param [Fixnum] column Column the problem was found on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) before a }, "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column, msg,
            @options[:level])
        end
      end

      # For Ruby versions < 2.0.0-p0, this has to keep track of +{+'s and only
      # follow through with the check if the +{+ was an lbrace because Ripper
      # doesn't scan the +}+ of an embedded expression (embexpr_end) as such.
      #
      # @param [Tailor::LexedLine] lexed_line
      # @param [Fixnum] lineno
      # @param [Fixnum] column
      def rbrace_update(lexed_line, lineno, column)
        if RUBY_VERSION < '2.0.0' && @lbrace_nesting.last == :embexpr_beg
          @lbrace_nesting.pop
          return
        end

        @lbrace_nesting.pop

        count = count_spaces(lexed_line, column)
        log "Found #{count} space(s) before rbrace."

        if !@do_measurement
          log 'Skipping measurement.'
        else
          measure(count, lineno, column)
        end

        @do_measurement = true
      end
    end
  end
end
