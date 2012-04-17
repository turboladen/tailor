require_relative '../ruler'

class Tailor
  module Rulers
    class AllowTrailingLineSpacesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :ignored_nl, :nl
      end

      def ignored_nl_update(lexed_line, lineno, column)
        log "Last event: #{lexed_line.last_non_line_feed_event}"
        log "Line ends with space: #{lexed_line.ends_with_sp?}"

        measure(lexed_line, lineno, column)
      end

      def nl_update(lexed_line, lineno, column)
        ignored_nl_update(lexed_line, lineno, column)
      end

      # Checks to see if the line contains trailing spaces.
      #
      # @param [LexedLine] lexed_line The line to check for trailing spaces.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(lexed_line, lineno, column)
        if lexed_line.ends_with_sp?
          actual = lexed_line.last_non_line_feed_event.last.size
          problem_message = "Line has #{actual} trailing spaces."

          @problems << Problem.new(problem_type, lineno, column,
            problem_message, @options[:level])
        end
      end
    end
  end
end
