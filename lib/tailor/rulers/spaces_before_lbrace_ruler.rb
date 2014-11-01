require_relative '../ruler'

class Tailor
  module Rulers
    # Detects spaces before a +{+ as given by +@config+.  It skips checking
    # when:
    # * it's the first char in the line.
    # * the char before it is a '#{'.
    # * the char before it is a '('.
    # * the char before it is a '['.
    # * it's only preceded by spaces.
    class SpacesBeforeLbraceRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :lbrace
      end

      # Counts the spaces before the '{'.
      #
      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] The number of spaces before the lbrace.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil?
          log 'lbrace must be at the beginning of the line.'
          @do_measurement = false
          return 0
        end

        if previous_event[1] == :on_embexpr_beg
          log "lbrace comes after a '\#{'."
          @do_measurement = false
          return 0
        end

        if previous_event[1] == :on_lparen
          log "lbrace comes after a '('."
          @do_measurement = false
          return 0
        end

        if previous_event[1] == :on_lbracket
          log "lbrace comes after a '['."
          @do_measurement = false
          return 0
        end

        return 0 if previous_event[1] != :on_sp

        if current_index - 2 < 0
          log 'lbrace comes at the beginning of an indented line.'
          @do_measurement = false
          return previous_event.last.size
        end

        previous_event.last.size
      end

      # Called by {Lexer} when :on_lbrace is encountered.
      #
      # @param [LexedLine] lexed_line
      # @param [Fixnum] lineno
      # @param [Fixnum] column
      def lbrace_update(lexed_line, lineno, column)
        count = count_spaces(lexed_line, column)
        log "Found #{count} space(s) before lbrace."

        if !@do_measurement
          log 'Skipping measurement.'
        else
          measure(count, lineno, column)
        end

        @do_measurement = true
      end

      # Checks to see if the counted spaces before an lbrace equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces before the lbrace.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) before a {, "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column, msg,
            @options[:level])
        end
      end
    end
  end
end
