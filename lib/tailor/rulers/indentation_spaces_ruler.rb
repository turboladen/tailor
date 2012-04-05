require_relative '../ruler'
require_relative '../lexer_constants'
require_relative '../lexed_line'
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

        @brace_nesting = []
        @bracket_nesting = []
        @paren_nesting = []
        @op_statement_nesting = []
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
        stop if @tstring_nesting.size > 0

        if current_lexed_line.line_ends_with_op?
          log "Line ends with op."

          # Are we nested in a multi-line operation yet?
          if @op_statement_nesting.empty?
            @op_statement_nesting << lineno

            if current_lexed_line.contains_keyword_to_indent? &&
              @modifier_in_line.nil?
              @in_keyword_plus_op = true
            else
              msg = "Increasing :next_line expectation due to "
              msg << "multi-line operator statement."
              log msg
              @amount_to_change_next += 1
            end

            # If this line is a continuation of the last multi-line op statement
            # then update the nesting line number with this line number.
          else
            @op_statement_nesting.pop
            @op_statement_nesting << lineno
          end
        end

        if @op_statement_nesting.empty? &&
          @tstring_nesting.empty? &&
          @paren_nesting.empty? &&
          @brace_nesting.empty? &&
          @bracket_nesting.empty?
          if current_lexed_line.line_ends_with_comma?
            if current_lexed_line.contains_keyword_to_indent? &&
              @modifier_in_line.nil?
              log "In keyword-plus-comma statement."
              @in_keyword_plus_comma = true
            elsif @last_comma_statement_line.nil?
              msg = "Increasing :next_line expectation due to "
              msg << "multi-line comma statement."
              log msg
              @amount_to_change_next += 1
            end

            @last_comma_statement_line = lineno
            log "last_comma_statement_line: #{@last_comma_statement_line}"
          end
        end

        if current_lexed_line.line_ends_with_period?
          if current_lexed_line.contains_keyword_to_indent? &&
            @modifier_in_line.nil?
            @in_keyword_plus_period = true
          elsif @last_period_statement_line.nil?
            msg = "Increasing :next_line expectation due to "
            msg << "multi-line period statement."
            log msg
            @amount_to_change_next += 1
          end

          @last_period_statement_line = lineno
          log "last_period_statement_line: #{@last_period_statement_line}"
        end

        set_up_line_transition

        if current_lexed_line.only_spaces?
          log "Line of only spaces.  Moving on."
          return
        else
          update_actual_indentation(current_lexed_line)
          measure(lineno, column)
        end

        # prep for next line
        @modifier_in_line = nil
        transition_lines
      end

      def kw_update(token, lineno, column)
        if token.keyword_to_indent?
          log "Indent keyword found: '#{token}'."
          @indent_keyword_line = lineno

          if token.modifier_keyword?
            log "Found modifier in line: '#{token}'"
            @modifier_in_line = token
          elsif token.do_is_for_a_loop?
            log "Found keyword loop using optional 'do'"
          else
            log "Keyword '#{token}' not used as a modifier."

            if token.continuation_keyword?
              msg = "Continuation keyword: '#{token}'.  "
              msg << "Decreasing indent expectation for this line."
              log msg
              @amount_to_change_this -= 1
            else
              msg = "Keyword '#{token}' is not a continuation keyword.  "
              msg << "Increasing indent expectation for next line."
              log msg
              @amount_to_change_next += 1
            end
          end
        end

        if token == "end"
          unless single_line_indent_statement?(lineno)
            msg = "End of not a single-line statement that needs indenting."
            msg < "Decrease this line."
            log msg
            @amount_to_change_this -= 1
          end

          log "Decreasing next due to keyword 'end'."
          @amount_to_change_next -= 1
        end
      end

      def lbrace_update(lexed_line, lineno, column)
        @brace_nesting << lineno
        @amount_to_change_next += 1
      end

      def lbracket_update(lexed_line, lineno, column)
        @bracket_nesting << lineno
        @amount_to_change_next += 1
      end

      def lparen_update(lineno, column)
        @paren_nesting << lineno
        @amount_to_change_next += 1
      end

      def nl_update(current_lexed_line, lineno, column)
        update_actual_indentation(current_lexed_line)

        unless @op_statement_nesting.empty?
          log "op nesting not empty: #{@op_statement_nesting}"
          update_for_op_statement(lineno)
        end

        if !multi_line_braces?(lineno) &&
          !multi_line_brackets?(lineno) &&
          !multi_line_parens?(lineno)
          update_for_comma_statement(lineno)
        end

        update_for_period_statement(lineno)

        set_up_line_transition

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        @modifier_in_line = nil
        @in_keyword_plus_op = false
        @in_keyword_plus_comma = false
        @in_keyword_plus_period = false
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

          if r_event_without_content?(current_lexed_line, lineno, column)
            @amount_to_change_this -= 1
          end
        end

        @brace_nesting.pop

        # Ripper won't match a closing } in #{} so we have to track if we're
        # inside of one.  If we are, don't decrement then :next_line.
        unless @embexpr_beg
          @amount_to_change_next -= 1
        end

        @embexpr_beg = false
      end

      def rbracket_update(current_lexed_line, lineno, column)
        if multi_line_brackets?(lineno)
          log "End of multi-line brackets!"

          if r_event_without_content?(current_lexed_line, lineno, column)
            @amount_to_change_this -= 1
          end
        end

        @bracket_nesting.pop
        @amount_to_change_next -= 1
      end

      def rparen_update(current_lexed_line, lineno, column)
        if multi_line_parens?(lineno)
          log "End of multi-line parens!"

          if r_event_without_content?(current_lexed_line, lineno, column)
            @amount_to_change_this -= 1
          end
        end

        @paren_nesting.pop
        @amount_to_change_next -= 1
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
