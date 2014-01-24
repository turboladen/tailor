require_relative '../ruler'

class Tailor
  module Rulers

    # Checks for spaces after a +{+ as given by +@config+.  It skips checking
    # when:
    # * it's at the end of a line.
    # * the next char is a '}'
    # * it's at the end of a line, followed by a trailing comment.
    class SpacesAfterLbraceRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :comment, :ignored_nl, :lbrace, :nl
        @lbrace_columns = []
      end

      def comment_update(token, lexed_line, _, lineno, column)
        if token =~ /\n$/
          log 'Found comment with trailing newline.'
          ignored_nl_update(lexed_line, lineno, column)
        end
      end

      def ignored_nl_update(lexed_line, lineno, _)
        check_spaces_after_lbrace(lexed_line, lineno)
      end

      def lbrace_update(_, _, column)
        @lbrace_columns << column
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the number of spaces after an lbrace equals the value
      # at +@config+.
      #
      # @param [Fixnum] actual_spaces The number of spaces after the lbrace.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(actual_spaces, lineno, column)
        if actual_spaces != @config
          msg = "Line has #{actual_spaces} space(s) after a {, "
          msg << "but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column + 1, msg,
            @options[:level])
        end
      end

      def check_spaces_after_lbrace(lexed_line, lineno)
        log "lbraces found at: #{@lbrace_columns}" unless @lbrace_columns.empty?

        @lbrace_columns.each do |column|
          actual_spaces = count_spaces(lexed_line, column)
          next if actual_spaces.nil?

          if !@do_measurement
            log 'Skipping measurement.'
          else
            measure(actual_spaces, lineno, column)
          end

          @do_measurement = true
        end

        @lbrace_columns.clear
      end

      # Counts the number of spaces after the lbrace.
      #
      # @param [LexedLine] lexed_line The LexedLine that contains the context
      #   the lbrace was found in.
      # @param [Fixnum] column Column the lbrace was found at.
      # @return [Fixnum] The number of spaces found after the lbrace.
      def count_spaces(lexed_line, column)
        event_index = lexed_line.event_index(column)

        if event_index.nil?
          log 'No lbrace in this line.  Moving on...'
          @do_measurement = false
          return
        end

        next_event = lexed_line.at(event_index + 1)

        if next_event.nil?
          log 'lbrace must be at the end of the line.  Moving on.'
          @do_measurement = false
          return 0
        end

        if next_event[1] == :on_nl || next_event[1] == :on_ignored_nl
          log "lbrace is followed by a '#{next_event[1]}'.  Moving on."
          @do_measurement = false
          return 0
        end

        if next_event[1] == :on_rbrace
          log 'lbrace is followed by an rbrace.  Moving on.'
          @do_measurement = false
          return 0
        end

        second_next_event = lexed_line.at(event_index + 2)
        if second_next_event[1] == :on_comment
          log 'Event + 2 is a comment.'
          @do_measurement = false
          return next_event.last.size
        end

        next_event[1] != :on_sp ? 0 : next_event.last.size
      end
    end
  end
end
