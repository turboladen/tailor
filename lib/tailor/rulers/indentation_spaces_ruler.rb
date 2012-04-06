require_relative '../ruler'
require_relative '../lexer_constants'
require_relative '../lexed_line'
require_relative '../lexer/token'
require_relative 'indentation_spaces_ruler/indentation_helpers'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      include LexerConstants
      include IndentationHelpers

      def initialize(config)
        super(config)
        @proper = {}
        log "Setting @proper[:this_line] to 0."
        @proper[:this_line] = 0
        @proper[:next_line] = 0
        @actual_indentation = 0

        @double_tokens = []
        @tstring_nesting = []
        @single_tokens = []

        @amount_to_change_next = 0
        @amount_to_change_this = 0
      end

      def comment_update(token, lexed_line, file_text, lineno, column)
        # trailing comment?
        if token.ends_with_newline?
          log "Comment ends with newline.  Removing comment..."
          log "Old lexed line: #{lexed_line.inspect}"

          new_lexed_line = lexed_line.remove_trailing_comment(file_text)

          log "New lexed line: #{new_lexed_line.inspect}"

          if new_lexed_line.ends_with_ignored_nl?
            log "New lexed line ends with :on_ignored_nl."
            ignored_nl_update(new_lexed_line, lineno, column)
          elsif new_lexed_line.ends_with_nl?
            log "New lexed line ends with :on_nl."
            nl_update(new_lexed_line, lineno, column)
          end
        end
      end

      def embexpr_beg_update
        @embexpr_beg = true
      end

      def embexpr_end_update
        @embexpr_beg = false
      end

      def ignored_nl_update(current_lexed_line, lineno, column)
        log "double tokens on entry: #{@double_tokens}"
        log "single tokens on entry: #{@single_tokens}"
        stop if @tstring_nesting.size > 0

        if current_lexed_line.only_spaces?
          log "Line of only spaces.  Moving on."
          # todo: maybe i shouldn't return here? ...do transitions?
          return
        end

        if single_token_indent_line_end?(current_lexed_line)
          log "Line ends with single-token indent token."

          unless comma_is_part_of_enclosed_statement?(current_lexed_line, lineno)
            token_event = current_lexed_line.last_non_line_feed_event

            unless line_ends_with_same_as_last token_event
              @amount_to_change_next += 1
              msg = "Single-token-indent line-end; token: #{token_event[1]}. "
              msg << "change_next += 1 -> #{@amount_to_change_next}"
            end

            @single_tokens << { token: token_event.last, lineno: lineno }
          end

          if keyword_and_single_token_line?(lineno)
            @amount_to_change_next -= 1
            msg = "Single-token ends a keyword-opening line.  "
            msg << "change_next -= 1 -> #{@amount_to_change_next}"
          end
        end

        set_up_line_transition
        update_actual_indentation(current_lexed_line)
        measure(lineno, column)

        log "double tokens on exit: #{@double_tokens}"
        log "single tokens on entry: #{@single_tokens}"
        # prep for next line
        transition_lines
      end

      def kw_update(token, lexed_line, lineno, column)
        if token.keyword_to_indent?
          log "Indent keyword found: '#{token}'."
          update_for_opening_double_token(token, lineno)
        end

        if token == "end"
          update_for_closing_double_token(:kw, lexed_line)
        end
      end

      def lbrace_update(lexed_line, lineno, column)
        token = Tailor::Lexer::Token.new('{')
        update_for_opening_double_token(token, lineno)
      end

      def lbracket_update(lexed_line, lineno, column)
        token = Tailor::Lexer::Token.new('[')
        update_for_opening_double_token(token, lineno)
      end

      def lparen_update(lineno, column)
        token = Tailor::Lexer::Token.new('(')
        update_for_opening_double_token(token, lineno)
      end

      def nl_update(current_lexed_line, lineno, column)
        log "double tokens on entry: #{@double_tokens}"
        log "single tokens on entry: #{@single_tokens}"
        update_actual_indentation(current_lexed_line)

        unless @single_tokens.empty?
          log "End of single-token statement."

          if single_token_start_line == double_token_start_line
            log "Single-token started at same time as double-token."
          else
            @amount_to_change_next -= 1
            log "change_next -= 1 -> #{@amount_to_change_next}"
          end

          @single_tokens.clear
        end

        set_up_line_transition

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        log "double tokens on exit: #{@double_tokens}"
        log "single tokens on entry: #{@single_tokens}"
        transition_lines
      end

      def rbrace_update(current_lexed_line, lineno, column)
        if multi_line_braces?(lineno)
          log "End of multi-line braces!"

          # todo: change to lexed_line.only_rbrace?
          if r_event_without_content?(current_lexed_line, lineno, column)
            @amount_to_change_this -= 1
          end
        end

        update_for_closing_double_token(:rbrace, current_lexed_line)

        # Ripper won't match a closing } in #{} so we have to track if we're
        # inside of one.  If we are, don't decrement then :next_line.
        #unless @embexpr_beg
        #  @amount_to_change_next -= 1
        #  msg = "rbrace: "
        #  msg << "change_next -= 1 -> #{@amount_to_change_next}"
        #  log msg
        #end
      end

      def rbracket_update(current_lexed_line, lineno, column)
        if multi_line_brackets?(lineno)
          log "End of multi-line brackets!"

          if r_event_without_content?(current_lexed_line, lineno, column)
            @amount_to_change_this -= 1
          end
        end

        update_for_closing_double_token(:rbracket, current_lexed_line)
      end

      def rparen_update(current_lexed_line, lineno, column)
        if multi_line_parens?(lineno)
          log "End of multi-line parens!"

          if r_event_without_content?(current_lexed_line, lineno, column)
            log "r event without content"
            @amount_to_change_this -= 1
          end
        end

        update_for_closing_double_token(:rparen, current_lexed_line)
      end

      def tstring_beg_update(lineno)
        @tstring_nesting << lineno
        stop
      end

      def tstring_end_update
        @tstring_nesting.pop
        start unless in_tstring?
      end
    end
  end
end
