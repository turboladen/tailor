require_relative '../ruler'
require_relative '../lexed_line'
require_relative '../lexer/token'
require_relative 'indentation_spaces_ruler/indentation_manager'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      def initialize(config)
        super(config)
        add_lexer_observers(
          :comment,
          :embexpr_beg,
          :embexpr_end,
          :ignored_nl,
          :kw,
          :lbrace,
          :lbracket,
          :lparen,
          :nl,
          :rbrace,
          :rbracket,
          :rparen,
          :tstring_beg,
          :tstring_end
        )
        @manager = IndentationManager.new(@config)
        @embexpr_beg = false
        @tstring_nesting = []
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

      # Due to a Ripper bug (depending on which Ruby version you have), this may
      # or may not get triggered.
      # More info: https://bugs.ruby-lang.org/issues/6211
      def embexpr_end_update
        @embexpr_beg = false
      end

      def ignored_nl_update(current_lexed_line, lineno, column)
        log "indent reasons on entry: #{@manager.indent_reasons}"
        stop if @tstring_nesting.size > 0

        if current_lexed_line.only_spaces?
          log "Line of only spaces.  Moving on."
          # todo: maybe i shouldn't return here? ...do transitions?
          return
        end

        if @manager.line_ends_with_single_token_indenter?(current_lexed_line)
          log "Line ends with single-token indent token."

          unless @manager.in_an_enclosure? && current_lexed_line.ends_with_comma?
            log "Line-ending single-token indenter found."
            token_event = current_lexed_line.last_non_line_feed_event

            unless @manager.line_ends_with_same_as_last token_event
              log "Line ends with different type of single-token indenter: #{token_event}"
              @manager.add_indent_reason(token_event[1], token_event.last, lineno)
            end
          end
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
          @manager.update_for_closing_reason(:on_kw, lexed_line, lineno)
          return
        end

        if token.continuation_keyword?
          log "Continuation keyword found: '#{token}'."
          @manager.update_for_continuation_reason(token, lexed_line, lineno)
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
        log "indent reasons on entry: #{@manager.indent_reasons}"
        @manager.update_actual_indentation(current_lexed_line)

        if @manager.last_indent_reason_type != :on_kw &&
          @manager.last_indent_reason_type != :on_lbrace &&
          @manager.last_indent_reason_type != :on_lbracket &&
          @manager.last_indent_reason_type != :on_lparen &&
          !@manager.last_indent_reason_type.nil?
          log "last indent reason type: #{@manager.last_indent_reason_type}"
          log "I think this is a single-token closing line..."

          @manager.update_for_closing_reason(@manager.indent_reasons.last[:event_type],
            current_lexed_line, lineno)
        end

        @manager.set_up_line_transition

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        log "indent reasons on exit: #{@manager.indent_reasons}"
        @manager.transition_lines
      end

      # Since Ripper parses the } in a #{} as :on_rbrace instead of
      # :on_embexpr_end, this works around that by using +@embexpr_beg to track
      # the state of that event.  As such, this should only be called from
      # #rbrace_update.
      #
      # @return [Boolean]
      def in_embexpr?
        @embexpr_beg == true
      end

      def rbrace_update(current_lexed_line, lineno, column)
        if in_embexpr?
          msg = "Got :rbrace and @embexpr_beg is true. "
          msg << " Must be at an @embexpr_end."
          log msg
          @embexpr_beg = false
          return
        end

        if @manager.multi_line_braces?(lineno)
          log "End of multi-line braces!"

          if current_lexed_line.only_rbrace?
            @manager.amount_to_change_this -= 1
            log "lonely rbrace.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rbrace, current_lexed_line, lineno)
      end

      def rbracket_update(current_lexed_line, lineno, column)
        if @manager.multi_line_brackets?(lineno)
          log "End of multi-line brackets!"

          if current_lexed_line.only_rbracket?
            @manager.amount_to_change_this -= 1
            log "lonely rbracket.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rbracket, current_lexed_line, lineno)
      end

      def rparen_update(current_lexed_line, lineno, column)
        if @manager.multi_line_parens?(lineno)
          log "End of multi-line parens!"

          if current_lexed_line.only_rparen?
            @manager.amount_to_change_this -= 1
            log "lonely rparen.  change_this -= 1 -> #{@manager.amount_to_change_this}"
          end
        end

        @manager.update_for_closing_reason(:on_rparen, current_lexed_line, lineno)
      end

      def tstring_beg_update(lineno)
        @tstring_nesting << lineno
        @manager.stop
      end

      def tstring_end_update
        @tstring_nesting.pop
        @manager.start unless in_tstring?
      end

      def in_tstring?
        !@tstring_nesting.empty?
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
