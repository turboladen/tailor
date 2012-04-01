require_relative '../ruler'

class Tailor
  module Rulers

    # Checks for spaces before a '}' as given by +@config+.  It skips checking
    # when:
    # * it's the first char in the line.
    # * it's the first char in the line, preceded by spaces.
    # * it's directly preceded by a '{'.
    class SpacesBeforeRbraceRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @lbrace_nesting = []
        @do_validation = true
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
          log "rbrace is at the beginning of the line."
          @do_validation = false
          return 0
        end

        if previous_event[1] == :on_lbrace
          log "rbrace comes after a '{'"
          @do_validation = false
          return 0
        end

        return 0 if previous_event[1] != :on_sp

        # todo: I forget why this is here...
        #if current_index - 2 < 0
        #  @do_validation = false
        #  return 0
        #end

        previous_event.last.size
      end

      def embexpr_beg_update
        @lbrace_nesting << :embexpr_beg
      end

      def lbrace_update(lexed_line, lineno, column)
        @lbrace_nesting << :lbrace
      end

      # This has to keep track of '{'s and only follow through with the check
      # if the '{' was an lbrace because Ripper doesn't scan the '}' of an
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

        if @do_validation == false
          return
        else
          log "Found #{count} space(s) before rbrace."
        end

        if count != @config
          @problems << Problem.new(:spaces_before_rbrace, lineno, column,
            { actual_spaces: count, should_have: @config })
        end
      end
    end
  end
end
