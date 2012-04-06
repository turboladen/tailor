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
        @last_comma_statement_line = nil
        @last_period_statement_line = nil

        @amount_to_change_next = 0
        @amount_to_change_this = 0
      end

      def comma_update(text_line, lineno, column)
        if column == text_line.length
          log "Line ends with comma."
          @last_comma_statement_line = lineno
        end
      end

      def comment_update(token, lexed_line, file_text, lineno, column)
        # trailing comment?
        if token.ends_with_newline?
          log "Comment ends with newline.  Removing comment..."
          log "Old lexed line: #{lexed_line.inspect}"

          new_lexed_line = lexed_line.remove_trailing_comment(file_text)

          log "New lexed line: #{new_lexed_line.inspect}"

          if new_lexed_line.line_ends_with_ignored_nl?
            log "New lexed line ends with :on_ignored_nl."
            ignored_nl_update(new_lexed_line, lineno, column)
          elsif new_lexed_line.line_ends_with_nl?
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
        stop if @tstring_nesting.size > 0

        if current_lexed_line.only_spaces?
          log "Line of only spaces.  Moving on."
          return
        end

        if current_lexed_line.line_ends_with_op?
          update_for_start_of_op_statement(current_lexed_line, lineno)
        end

        if !in_a_nested_statement? &&
          current_lexed_line.line_ends_with_comma?
          update_for_start_of_comma_statement(current_lexed_line, lineno)
        end

        if current_lexed_line.line_ends_with_period?
          update_for_start_of_period_statement(current_lexed_line, lineno)
        end

        set_up_line_transition
        update_actual_indentation(current_lexed_line)
        measure(lineno, column)

        log "double tokens on exit: #{@double_tokens}"
        # prep for next line
        @modifier_in_line = nil
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
        update_actual_indentation(current_lexed_line)

        unless @op_statement_nesting.empty?
          log "op nesting not empty: #{@op_statement_nesting}"
          update_for_end_of_op_statement(lineno)
        end

        unless continuing_enclosed_statement?(lineno)
          update_for_end_of_comma_statement(lineno)
        end

        update_for_end_of_period_statement(lineno)
        set_up_line_transition

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        log "double tokens on exit: #{@double_tokens}"
        reset_keyword_state
        transition_lines
      end

      def period_update(current_line_length, lineno, column)
        if column == current_line_length
          log "Line length: #{current_line_length}"
          @last_period_statement_line = lineno
        end
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
