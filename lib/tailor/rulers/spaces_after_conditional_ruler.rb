require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesAfterConditionalRuler < Tailor::Ruler

      def initialize(config, options)
        super(config, options)
        add_lexer_observers :nl
      end

      def nl_update(current_lexed_line, lineno, _)
        measure(current_lexed_line, lineno)
      end

      # Checks to see if spacing is present after conditionals
      #
      # @param [Array] lexed_line The lexed line with a conditional
      # @param [Fixnum] lineno Line the problem was found on.
      def measure(lexed_line, lineno)

        idx = lexed_line.index do |_, token, name|
          token == :on_kw and %w{if unless case}.include?(name)
        end

        expected_spaces = @config
        spaces = expected_spaces

        if idx
          column = lexed_line[idx].first.last
          pos, token, _ = lexed_line[idx + 1]
          spaces = case token
          when :on_lparen then 0
          when :on_sp
            next_token = lexed_line[idx + 2]
            next_token.first.last - pos.last
          end
        end

        if expected_spaces != spaces
          @problems << Problem.new(problem_type, lineno, column,
            "#{spaces} spaces after conditional at column #{column}, " +
              "expected #{expected_spaces}.", @options[:level])
        end
      end
    end
  end
end
