require_relative '../ruler'
require_relative '../lexed_line'
require_relative '../lexer/token'
require_relative 'indentation_spaces_ruler/indentation_manager'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        @manager = IndentationManager.new(@config)
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
        @manager.embexpr_beg = true
      end

      def embexpr_end_update
        @manager.embexpr_beg = false
      end

      def ignored_nl_update(current_lexed_line, lineno, column)
        log "double tokens on entry: #{@manager.indent_reasons}"
        stop if @manager.tstring_nesting.size > 0

        if current_lexed_line.only_spaces?
          log "Line of only spaces.  Moving on."
          # todo: maybe i shouldn't return here? ...do transitions?
          return
        end

        if @manager.line_ends_with_single_token_indenter?(current_lexed_line)
          log "Line ends with single-token indent token."

          unless @manager.comma_is_part_of_enclosed_statement?(current_lexed_line, lineno)
            log "Line-ending single-token indenter found."
            token_event = current_lexed_line.last_non_line_feed_event

            unless @manager.line_ends_with_same_as_last token_event
              log "Line ends with different type of single-token indenter: #{token_event}"
=begin
              @manager.amount_to_change_next += 1
              msg = "Single-token-indent line-end; token: #{token_event[1]}. "
              msg << "change_next += 1 -> #{@manager.amount_to_change_next}"
              log msg
=end
              @manager.add_indent_reason(token_event[1], token_event.last, lineno)
            end
          end

=begin
          if @manager.keyword_and_single_token_line?(lineno)
            @manager.amount_to_change_next -= 1
            msg = "Single-token ends a keyword-opening line.  "
            msg << "change_next -= 1 -> #{@manager.amount_to_change_next}"
            log msg
          end
=end
        end

        @manager.update_actual_indentation(current_lexed_line)
        @manager.set_up_line_transition
        measure(lineno, column)

        log "indent reasons on exit: #{@manager.indent_reasons}"
        # prep for next line
        @manager.transition_lines
      end

      def kw_update(token, lexed_line, lineno, column)
        if token == "end"
          @manager.update_for_closing_reason(:on_kw, token, lexed_line)
          return
        end

        if token.continuation_keyword?
          log "Continuation keyword found: '#{token}'."
          @manager.update_for_continuation_reason(:on_kw, token, lineno)
          return
        end

        if token.keyword_to_indent?
          log "Indent keyword found: '#{token}'."
          @manager.update_for_opening_reason(:on_kw, token, lineno)
        end
      end

      def lbrace_update(lexed_line, lineno, column)
        token = Tailor::Lexer::Token.new('{')
        @manager.update_for_opening_reason(:on_lbrace, token, lineno)
      end

      def lbracket_update(lexed_line, lineno, column)
        token = Tailor::Lexer::Token.new('[')
        @manager.update_for_opening_reason(:on_lbracket, token, lineno)
      end

      def lparen_update(lineno, column)
        token = Tailor::Lexer::Token.new('(')
        @manager.update_for_opening_reason(:on_lparen, token, lineno)
      end

      def nl_update(current_lexed_line, lineno, column)
        log "double tokens on entry: #{@manager.indent_reasons}"
        @manager.update_actual_indentation(current_lexed_line)

        #unless @manager.single_tokens.empty?
        if @manager.last_indent_reason_type != :on_kw &&
          @manager.last_indent_reason_type != :on_lbrace &&
          @manager.last_indent_reason_type != :on_lbracket &&
          @manager.last_indent_reason_type != :on_lparen &&
          !@manager.last_indent_reason_type.nil?
          log "last indent reason type: #{@manager.last_indent_reason_type}"
          # if double tokens exist after the last single token, it's not the end
          # of the single-token statement.
=begin
          double_in_a_single = @manager.indent_reasons.find do |t|
            t[:lineno] > @manager.single_tokens.last[:lineno]
          end

          unless double_in_a_single.empty?
            log "End of single-token statement."

            if @manager.single_token_start_line == @manager.double_token_start_line
              log "Single-token started at same time as double-token."
            else
              @manager.amount_to_change_next -= 1
              log "change_next -= 1 -> #{@manager.amount_to_change_next}"
            end

            @manager.single_tokens.clear
          end
=end
          @manager.update_for_closing_reason(@manager.indent_reasons.last[:event_type],
            @manager.indent_reasons.last[:token], current_lexed_line)
        end

        @manager.set_up_line_transition

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        log "double tokens on exit: #{@manager.indent_reasons}"
        @manager.transition_lines
      end

      def rbrace_update(current_lexed_line, lineno, column)
        if @manager.multi_line_braces?(lineno)
          log "End of multi-line braces!"

          if current_lexed_line.only_rbrace?
            @manager.amount_to_change_this -= 1
            log "lonely rbrace.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rbrace, '}', current_lexed_line)

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
        if @manager.multi_line_brackets?(lineno)
          log "End of multi-line brackets!"

          if current_lexed_line.only_rbracket?
            @manager.amount_to_change_this -= 1
            log "lonely rbracket.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rbracket, ']', current_lexed_line)
      end

      def rparen_update(current_lexed_line, lineno, column)
        if @manager.multi_line_parens?(lineno)
          log "End of multi-line parens!"

          if current_lexed_line.only_rparen?
            @manager.amount_to_change_this -= 1
            log "lonely rparen.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rparen, ')', current_lexed_line)
      end

      def tstring_beg_update(lineno)
        @manager.tstring_nesting << lineno
        @manager.stop
      end

      def tstring_end_update
        @manager.tstring_nesting.pop
        @manager.start unless @manager.in_tstring?
      end

      # Checks if the line's indentation level is appropriate.
      #
      # @param [Fixnum] lineno The line the potential problem is on.
      # @param [Fixnum] column The column the potential problem is on.
      def measure(lineno, column)
        log "Measuring..."

        if @manager.actual_indentation != @manager.should_be_at
          @problems << Problem.new(:indentation, lineno, column,
            { actual_indentation: @manager.actual_indentation,
              should_be_at: @manager.should_be_at }
          )
        end
      end
    end
  end
end
