require 'nokogiri'
require_relative '../ruler'
require_relative '../lexed_line'
require_relative '../lexer/token'
require_relative 'indentation_spaces_ruler/argument_alignment'
require_relative 'indentation_spaces_ruler/indentation_manager'
require_relative 'indentation_spaces_ruler/line_continuations'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      def initialize(config, options)
        super(config, options)
        add_lexer_observers(
          :comment,
          :embexpr_beg,
          :embexpr_end,
          :file_beg,
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
        @embexpr_nesting = []
        @tstring_nesting = []
      end

      def comment_update(token, lexed_line, file_text, lineno, column)
        if token.fake_backslash_line_end?
          log 'Line was altered by tailor to accommodate trailing backslash'
          @manager.add_indent_reason(:trailing_backslash, :trailing_backslash,
            lineno)
        end

        # trailing comment?
        if token.ends_with_newline?
          log 'Comment ends with newline.  Removing comment...'
          log "Old lexed line: #{lexed_line.inspect}"

          new_lexed_line = lexed_line.remove_trailing_comment(file_text)

          log "New lexed line: #{new_lexed_line.inspect}"

          if new_lexed_line.ends_with_ignored_nl?
            log 'New lexed line ends with :on_ignored_nl.'
            ignored_nl_update(new_lexed_line, lineno, column)
          elsif new_lexed_line.ends_with_nl?
            log 'New lexed line ends with :on_nl.'
            nl_update(new_lexed_line, lineno, column)
          end
        end
      end

      def embexpr_beg_update(lexed_line, lineno, column)
        @embexpr_nesting << true

        token = Tailor::Lexer::Token.new('{')
        @manager.update_for_opening_reason(:on_embexpr_beg, token, lineno)
      end

      # Due to a Ripper bug that was fixed in ruby 2.0.0-p0, this will not get
      # triggered if you're using 1.9.x.
      # More info: https://bugs.ruby-lang.org/issues/6211
      def embexpr_end_update(current_lexed_line, lineno, column)
        @embexpr_nesting.pop
        @manager.update_for_closing_reason(:on_embexpr_end, current_lexed_line)
      end

      def file_beg_update(file_name)
        # For statements that continue over multiple lines we may want to treat
        # the second and subsequent lines differently and ident them further,
        # controlled by the :line_continuations option.
        @lines = LineContinuations.new(file_name) if line_continuations?
        @args = ArgumentAlignment.new(file_name) if argument_alignment?
      end

      def ignored_nl_update(current_lexed_line, lineno, column)
        log "indent reasons on entry: #{@manager.indent_reasons}"

        if current_lexed_line.only_spaces?
          log 'Line of only spaces.  Moving on.'
          # todo: maybe i shouldn't return here? ...do transitions?
          return
        end

        if @manager.line_ends_with_single_token_indenter?(current_lexed_line)
          log 'Line ends with single-token indent token.'

          unless @manager.in_an_enclosure? &&
            current_lexed_line.ends_with_comma?
            log 'Line-ending single-token indenter found.'
            token_event = current_lexed_line.last_non_line_feed_event

            unless @manager.line_ends_with_same_as_last token_event
              msg = 'Line ends with different type of single-token '
              msg << "indenter: #{token_event}"
              log msg
              @manager.add_indent_reason(token_event[1], token_event.last,
                lineno)
            end
          end
        end

        @manager.update_actual_indentation(current_lexed_line)
        measure(lineno, column)

        log "indent reasons on exit: #{@manager.indent_reasons}"
        # prep for next line
        @manager.transition_lines
      end

      def kw_update(token, lexed_line, lineno, column)
        if lexed_line.keyword_is_symbol?
          log "Keyword is prefaced by a :, indicating it's really a Symbol."
          return
        end

        if token == 'end'
          @manager.update_for_closing_reason(:on_kw, lexed_line)
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
          log 'I think this is a single-token closing line...'

          @manager.update_for_closing_reason(@manager.indent_reasons.
            last[:event_type], current_lexed_line)
        end

        unless current_lexed_line.end_of_multi_line_string?
          measure(lineno, column)
        end

        log "indent reasons on exit: #{@manager.indent_reasons}"
        @manager.transition_lines
      end

      # Since Ripper in Ruby 1.9.x parses the } in a #{} as :on_rbrace instead of
      # :on_embexpr_end, this works around that by using +@embexpr_beg to track
      # the state of that event.  As such, this should only be called from
      # #rbrace_update.
      #
      # @return [Boolean]
      def in_embexpr?
        !@embexpr_nesting.empty?
      end

      def rbrace_update(current_lexed_line, lineno, column)
        # Is this an rbrace that should've been parsed as an embexpr_end?
        if in_embexpr? && RUBY_VERSION < '2.0.0'
          msg = 'Got :rbrace and @embexpr_beg is true. '
          msg << ' Must be at an @embexpr_end.'
          log msg
          @embexpr_nesting.pop
          @manager.update_for_closing_reason(:on_embexpr_end,
            current_lexed_line)

          return
        end

        @manager.update_for_closing_reason(:on_rbrace, current_lexed_line)
      end

      def rbracket_update(current_lexed_line, lineno, column)
        @manager.update_for_closing_reason(:on_rbracket, current_lexed_line)
      end

      def rparen_update(current_lexed_line, lineno, column)
        @manager.update_for_closing_reason(:on_rparen, current_lexed_line)
      end

      def tstring_beg_update(lexed_line, lineno)
        @tstring_nesting << lineno
        @manager.update_actual_indentation(lexed_line)
        log "tstring_nesting is now: #{@tstring_nesting}"
        @manager.stop
      end

      def tstring_end_update(current_line)
        unless @tstring_nesting.empty?
          tstring_start_line = @tstring_nesting.pop

          if tstring_start_line < current_line
            measure(tstring_start_line, @manager.actual_indentation)
          end
        end

        @manager.start unless in_tstring?
      end

      def in_tstring?
        !@tstring_nesting.empty?
      end

      def line_continuations?
        @options[:line_continuations] and @options[:line_continuations] != :off
      end

      def with_line_continuations(lineno, should_be_at)
        return should_be_at unless line_continuations?
        if @lines.line_is_continuation?(lineno) and
          @lines.line_has_nested_statements?(lineno)
          should_be_at + @config
        else
          should_be_at
        end
      end

      def argument_alignment?
        @options[:argument_alignment] and @options[:argument_alignment] != :off
      end

      def with_argument_alignment(lineno, should_be_at)
        return should_be_at unless argument_alignment?
        @args.expected_column(lineno, should_be_at)
      end

      # Checks if the line's indentation level is appropriate.
      #
      # @param [Fixnum] lineno The line the potential problem is on.
      # @param [Fixnum] column The column the potential problem is on.
      def measure(lineno, column)
        log 'Measuring...'

        should_be_at = with_line_continuations(lineno, @manager.should_be_at)
        should_be_at = with_argument_alignment(lineno, should_be_at)

        if @manager.actual_indentation != should_be_at
          msg = "Line is indented to column #{@manager.actual_indentation}, "
          msg << "but should be at #{should_be_at}."

          @problems << Problem.new(problem_type, lineno,
            @manager.actual_indentation, msg, @options[:level])
        end
      end
    end
  end
end
