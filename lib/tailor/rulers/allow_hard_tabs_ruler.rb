require_relative '../ruler'

class Tailor
  module Rulers
    class AllowHardTabsRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :sp
      end

      def sp_update(token, lineno, column)
        measure(token, lineno, column)
      end

      # Checks to see if the space(s) contains hard tabs.
      #
      # @param [Fixnum] token The space(s).
      # @param [Fixnum] lineno Line the problem was found on.
      # @param [Fixnum] column Column the problem was found on.
      def measure(token, lineno, column)
        if token.contains_hard_tab?
          problem_message = 'Hard tab found.'

          @problems << Problem.new(problem_type, lineno, column,
            problem_message, @options[:level])
        end
      end
    end
  end
end
