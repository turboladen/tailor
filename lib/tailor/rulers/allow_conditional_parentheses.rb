require_relative '../ruler'

class Tailor
  module Rulers
    class AllowConditionalParenthesesRuler < Tailor::Ruler
      def initialize(style, options)
        super(style, options)
        add_lexer_observers :nl
      end

      def nl_update(current_lexed_line, lineno, _)
        measure(current_lexed_line, lineno)
      end

      # Checks to see if a conditional is unnecessarily wrapped in parentheses.
      #
      # @param [Fixnum] line The current lexed line.
      # @param [Fixnum] lineno Line the problem was found on.
      def measure(line, lineno)
        return if @config
        return unless line.any? { |t| conditional?(t) }
        if tokens_before_lparen?(line) and ! tokens_after_rparen?(line)
          column = lparen_column(line)
          @problems << Problem.new('conditional_parentheses', lineno, column,
            "Parentheses around conditional expression at column #{column}.",
            @options[:level])
        end
      end

      private

      def conditional?(token)
        token[1] == :on_kw and %w{case if unless while}.include?(token[2])
      end

      def lparen?(token)
        token[1] == :on_lparen
      end

      def lparen_column(tokens)
        tokens.find { |t| lparen?(t) }[0][1] + 1
      end

      def tokens_before_lparen?(tokens)
        without_spaces(
          tokens.select do |t|
            true if (conditional?(t))..(lparen?(t))
          end.tap { |t| t.shift; t.pop }
        ).empty?
      end

      def tokens_after_rparen?(tokens)
        without_spaces(
          tokens.reverse.tap do |nl|
            nl.shift
          end.take_while { |t| t[1] != :on_rparen }
        ).any?
      end

      def without_spaces(tokens)
        tokens.reject { |t| t[1] == :on_sp }
      end
    end
  end
end
