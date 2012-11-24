require_relative '../ruler'

class Tailor
  module Rulers
    class QuotesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :tstring_beg
      end

      def tstring_beg_update(lexed_line, lineno, column, token)
        log "<#{self.class}> Line length: #{lexed_line.line_length}"
        measure(lexed_line, lineno, column, token)
      end

      # Checks to see if the usage of quotes is consistent and as expected by +@config+.
      #
      # @param [Fixnum] lexed_line The line to measure.
      # @param [Fixnum] lineno Line the potential problem is on.
      # @param [Fixnum] column Column the potential problem is on
      # @param [Fixnum] token Begin quote string
      def measure(lexed_line, lineno, column, token)
          spec = { "single" => "\"", "double" => "'" }
          if spec.has_key? @config and token == spec[@config]
            msg = "Use #{@config} quotes"

            @problems << Problem.new(problem_type, lineno, column, msg,
              @options[:level])
          end
      end
    end
  end
end
