require_relative '../ruler'

class Tailor
  module Rulers
    class AllowUnnecessaryDoubleQuotesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :nl
      end

      def nl_update(lexed_line, lineno, _)
        quotes(lexed_line).each do |quote|
          unless contains_embedded_expression?(quote) ||
            contains_escape_sequence?(quote)
            measure(lineno, column(quote.first))
          end
        end
      end

      # Checks to see if the double_quotes are unnecessary.
      #
      # @param [Fixnum] lineno Line the problem was found on.
      # @param [Fixnum] column Column the problem was found on.
      def measure(lineno, column)
        @problems << Problem.new('unnecessary_double_quotes', lineno, column,
          "Unnecessary double quotes at column #{column}, " +
            'expected single quotes.', @options[:level])
      end

      private

      def contains_embedded_expression?(tokens)
        tokens.any? { |t| t[1] == :on_embexpr_beg }
      end

      def contains_escape_sequence?(tokens)
        tokens.any? do |t|
          t[1] == :on_tstring_content and t[2].match(/\\[a-z]+/)
        end
      end

      def quotes(tokens)
        tokens.select do |t|
          true if (double_quote_start?(t))..(double_quote_end?(t))
        end.slice_before { |t| double_quote_start?(t) }.reject { |q| q.empty? }
      end

      def column(token)
        token[0][1]
      end

      def double_quote_start?(token)
        token[1] == :on_tstring_beg and token[2] == '"'
      end

      def double_quote_end?(token)
        token[1] == :on_tstring_end and token[2] == '"'
      end
    end
  end
end
