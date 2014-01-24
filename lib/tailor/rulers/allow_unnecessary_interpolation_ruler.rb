require_relative '../ruler'

class Tailor
  module Rulers
    class AllowUnnecessaryInterpolationRuler < Tailor::Ruler

      EVENTS = [
        :on_embexpr_beg,
        :on_embexpr_end,
        :on_rbrace,
        :on_tstring_beg,
        :on_tstring_content,
        :on_tstring_end
      ]

      def initialize(config, options)
        super(config, options)
        reset_tokens
        add_lexer_observers :ignored_nl, :nl
      end

      def ignored_nl_update(lexed_line, _, _)
        add_string_tokens(lexed_line)
      end

      def nl_update(lexed_line, _, _)
        add_string_tokens(lexed_line)
        each_string(@tokens).each do |string|
          measure(line_number(@tokens.first), string)
        end

        reset_tokens
      end

      # Checks if variables are interpolated unnecessarily.
      #
      # @param [Array] tokens The filtered tokens.
      def measure(lineno, tokens)
        return if @config
        if no_content?(tokens) and one_expression?(tokens)
          @problems << Problem.new('unnecessary_string_interpolation', lineno,
            column(tokens.first), 'Variable interpolated unnecessarily',
            @options[:level])
        end
      end

      private

      def add_string_tokens(lexed_line)
        @tokens += string_tokens(lexed_line)
      end

      def column(token)
        token.first.last + 1
      end

      def each_string(tokens)
        tokens.select do |t|
          true if (t[1] == :on_tstring_beg)..(t[1] == :on_tstring_end)
        end.slice_before { |t| t[1] == :on_tstring_beg }
      end

      def line_number(token)
        token.first.first
      end

      def no_content?(tokens)
        ! tokens.map { |t| t[1] }.include?(:on_tstring_content)
      end

      def one_expression?(tokens)
        tokens.select { |t| t[1] == :on_embexpr_beg }.size == 1 and
          tokens.select do |t|
            t[1] == :on_embexpr_end or t[1] == :on_rbrace
          end.any?
      end

      def reset_tokens
        @tokens = []
      end

      def string_tokens(lexed_line)
        lexed_line.select { |t| EVENTS.include?(t[1]) }
      end
    end
  end
end
