require 'ripper'
require_relative 'lexer_constants'
require_relative '../logger'

class Tailor
  class Lexer < ::Ripper::Lexer

    # Helper methods for tokens that are parsed by {Tailor::Lexer}.
    class Token < String
      include Tailor::LexerConstants
      include Tailor::Logger::Mixin

      # @param [String] the_token
      # @param [Hash] options
      def initialize(the_token, options={})
        super(the_token)
        @options = options
      end

      # Checks if +self+ is in +{KEYWORDS_TO_INDENT}+.
      #
      # @return [Boolean]
      def keyword_to_indent?
        KEYWORDS_TO_INDENT.include? self
      end

      # Checks if +self+ is in +{CONTINUATION_KEYWORDS}+.
      #
      # @return [Boolean]
      def continuation_keyword?
        CONTINUATION_KEYWORDS.include? self
      end

      # @return [Boolean]
      def ends_with_newline?
        self =~ /\n$/
      end

      # Checks if +self+ is "do" and +@options[:loop_with_do] is true.
      #
      # @return [Boolean]
      def do_is_for_a_loop?
        self == 'do' && @options[:loop_with_do]
      end

      # @return [Boolean]
      def screaming_snake_case?
        self =~ /[A-Z].*_/
      end

      # @return [Boolean]
      def contains_capital_letter?
        self =~ /[A-Z]/
      end

      # @return [Boolean]
      def contains_hard_tab?
        self =~ /\t/
      end

      # Checks the current line to see if +self+ is being used as a modifier.
      #
      # @return [Boolean] True if there's a modifier in the current line that
      #   is the same type as +token+.
      def modifier_keyword?
        return false unless keyword_to_indent?

        line_of_text = @options[:full_line_of_text]
        log "Line of text: #{line_of_text}"

        catch(:result) do
          sexp_line = Ripper.sexp(line_of_text)

          if sexp_line.nil?
            msg = 'sexp line was nil.  '
            msg << 'Perhaps that line is part of a multi-line statement?'
            log msg
            log 'Trying again with the last char removed from the line...'
            line_of_text.chop!
            sexp_line = Ripper.sexp(line_of_text)
          end

          if sexp_line.nil?
            log 'sexp line was nil again.'
            log 'Trying 1 more time with the last char removed from the line...'
            line_of_text.chop!
            sexp_line = Ripper.sexp(line_of_text)
          end

          if sexp_line.is_a? Array
            log "sexp_line.flatten: #{sexp_line.flatten}"
            log "sexp_line.last.first: #{sexp_line.last.first}"

            begin
              throw(:result, sexp_line.flatten.compact.any? do |s|
                s == MODIFIERS[self]
              end)
            rescue NoMethodError
            end
          end
        end
      end

      # @return [Boolean]
      def fake_backslash_line_end?
        self =~ /^# TAILOR REMOVED BACKSLASH\n?$/
      end
    end
  end
end
