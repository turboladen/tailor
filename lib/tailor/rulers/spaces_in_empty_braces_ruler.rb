require_relative '../ruler'

class Tailor
  module Rulers
    # Checks for spaces that exist between a +{+ and +}+ when there is only
    # space in between them.
    class SpacesInEmptyBracesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :embexpr_beg, :lbrace, :rbrace
        @lbrace_nesting = []
      end

      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] The number of spaces before the rbrace.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil?
          return
        end

        if previous_event[1] == :on_lbrace
          return 0
        end

        if previous_event[1] == :on_sp
          second_previous_event = lexed_line.at(current_index - 2)

          if second_previous_event[1] == :on_lbrace
            previous_event.last.size
          else
            nil
          end
        end
      end

      def embexpr_beg_update(_, _, _)
        @lbrace_nesting << :embexpr_beg
      end

      def lbrace_update(_, _, _)
        @lbrace_nesting << :lbrace
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the counted spaces between an lbrace and an rbrace
      # equals the value at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces before the lbrace.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) in between empty "
          msg << "braces, but should have #{@config}."

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
      def rbrace_update(lexed_line, lineno, column)
        if @lbrace_nesting.last == :embexpr_beg
          @lbrace_nesting.pop
          return
        end

        @lbrace_nesting.pop
        count = count_spaces(lexed_line, column)

        if count.nil?
          log "Braces aren't empty.  Moving on."
          return
        else
          log "Found #{count} space(s) before rbrace."
        end

        measure(count, lineno, column)
      end
    end
  end
end
