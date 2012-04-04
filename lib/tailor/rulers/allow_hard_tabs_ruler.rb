require_relative '../ruler'

class Tailor
  module Rulers
    class AllowHardTabsRuler < Tailor::Ruler
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
          @problems << Problem.new(:hard_tab, lineno, column)
        end
      end
    end
  end
end
