require 'ripper'
require_relative '../problem'


class Tailor
  class Lexer
    module VerticalWhitespaceHelpers

      # Counts the number of newlines at the end of the file.
      #
      # @param [String] text The file's text.
      # @return [Fixnum] The number of \n at the end of the file.
      def count_trailing_newlines(text)
        if text.end_with? "\n"
          count = 0

          text.reverse.chars do |c|
            if c == "\n"
              count += 1
            else
              break
            end
          end

          count
        else
          0
        end
      end

      # Checks to see if the file's final character is a \n.  If it is, it just
      # returns the text that was passed in.  If it's not, it adds a \n, since
      # the current indentation-checking algorithm only checks indent levels when
      # it parses a newline character (without this, indentation problems on the
      # final line won't ever get caught).
      #
      # @param [String] text The file's text.
      # @return [String] The file's text with a \n if there wasn't one there
      #   already.
      def ensure_trailing_newline(text)
        trailing_newline_count = count_trailing_newlines(text)

        if trailing_newline_count != @config[:vertical_spacing][:trailing_newlines]
          lineno = "<EOF>"
          column = "<EOF>"
          @problems << Problem.new(:trailing_newlines, binding)
          log "ERROR: Trailing Newlines.  #{@problems.last[:message]}"
        end

        trailing_newline_count > 0 ? text : (text + "\n")
      end
    end
  end
end
