require_relative '../ruler'

class Tailor
  module Rulers
    class HardTabRuler < Tailor::Ruler
      def sp_update(token, lineno, column)
        check_hard_tab(token, lineno, column)
      end

      def check_hard_tab(token, lineno, column)
        if token =~ /\t/
          @problems << Problem.new(:hard_tab, lineno, column)
        end
      end
    end
  end
end
