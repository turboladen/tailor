require_relative '../ruler'


class Tailor
  module Rulers
    class TrailingNewlinesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers :file_end
      end

      # Checks to see if the number of newlines at the end of the file is not
      # equal to the value at +@config+.
      #
      # @param [Fixnum] trailing_newline_count The number of newlines at the end
      #   of the file.
      def measure(trailing_newline_count)
        if trailing_newline_count != @config
          lineno = '<EOF>'
          column = '<EOF>'
          msg = "File has #{trailing_newline_count} trailing "
          msg << "newlines, but should have #{@config}."

          @problems << Problem.new(problem_type, lineno, column, msg,
            @options[:level])
        end
      end

      # Checks to see if the file's final character is a \n.  If it is, it just
      # returns the text that was passed in.  If it's not, it adds a \n, since
      # the current indentation-checking algorithm only checks indent levels when
      # it parses a newline character (without this, indentation problems on the
      # final line won't ever get caught).
      #
      # @param [Fixnum] trailing_newline_count
      def file_end_update(trailing_newline_count)
        measure(trailing_newline_count)
      end
    end
  end
end
