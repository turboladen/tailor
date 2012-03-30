require_relative '../ruler'


class Tailor
  module Rulers
    class TrailingNewlinesRuler < Tailor::Ruler

      # Checks to see if the file's final character is a \n.  If it is, it just
      # returns the text that was passed in.  If it's not, it adds a \n, since
      # the current indentation-checking algorithm only checks indent levels when
      # it parses a newline character (without this, indentation problems on the
      # final line won't ever get caught).
      #
      # @param [Fixnum] trailing_newline_count
      def file_update(trailing_newline_count)
        if trailing_newline_count != @config
          lineno = "<EOF>"
          column = "<EOF>"
          @problems << Problem.new(:trailing_newlines, lineno, column,
            { actual_trailing_newlines: trailing_newline_count,
              should_have: @config }
          )
          log "ERROR: Trailing Newlines.  #{@problems.last[:message]}"
        end
      end
    end
  end
end
