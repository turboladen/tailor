require_relative '../ruler'

class Tailor
  module Rulers
    class AllowScreamingSnakeCaseClassesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :const
      end

      def const_update(token, lexed_line, lineno, column)
        ident_index = lexed_line.event_index(column)
        previous_event = lexed_line.event_at(ident_index - 2)
        log "previous event: #{previous_event}"

        return if previous_event.nil?

        if previous_event[1] == :on_kw &&
          (previous_event.last == 'class' || previous_event.last == 'module')
          measure(token, lineno, column)
        end
      end

      # Checks to see if the class name matches /[A-Z].*_/.
      #
      # @param [Fixnum] token The space(s).
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on.
      def measure(token, lineno, column)
        if token.screaming_snake_case?
          problem_message = 'Screaming-snake-case class/module found.'

          @problems << Problem.new(problem_type, lineno, column,
            problem_message, @options[:level])
        end
      end
    end
  end
end
