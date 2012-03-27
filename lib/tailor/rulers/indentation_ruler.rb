require_relative '../ruler'
require_relative '../lexer_constants'
require_relative '../lexed_line'

class Tailor
  module Rulers
    class IndentationRuler < Tailor::Ruler
      include LexerConstants

      def initialize(config)
        super(config)
        @proper = {}
        log "Setting @proper[:this_line] to 0."
        @proper[:this_line] = 0
        @proper[:next_line] = 0
        @actual_indentation = 0
        @started = false

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

      # @return [Fixnum] The indent level the file should currently be at.
      def should_be_at
        @proper[:this_line]
      end

      def next_should_be_at
        @proper[:next_line]
      end

      # Decreases the indentation expectation for the current line by
      # +@config[:spaces]+.
      def decrease_this_line
        if started?
          @proper[:this_line] -= @config

          if @proper[:this_line] < 0
            @proper[:this_line] = 0
          end

          log "@proper[:this_line] = #{@proper[:this_line]}"
        else
          log "#decrease_this_line called, but checking is stopped."
        end
      end

      # Increases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def increase_next_line
        if started?
          @proper[:next_line] += @config
          log "@proper[:next_line] = #{@proper[:next_line]}"
        else
          log "#increase_this_line called, but checking is stopped."
        end
      end

      # Decreases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def decrease_next_line
        if started?
          @proper[:next_line] -= @config
          log "@proper[:next_line] = #{@proper[:next_line]}"
        else
          log "#decrease_next_line called, but checking is stopped."
        end
      end

      def set_up_line_transition
        log "Amount to change next line: #{@amount_to_change_next}"
        log "Amount to change this line: #{@amount_to_change_this}"
        if @amount_to_change_next > 0
          increase_next_line
        elsif @amount_to_change_next < 0
          decrease_next_line
        end

        if @amount_to_change_this < 0
          decrease_this_line
        end
      end

      # Should be called just before moving to the next line.  This sets the
      # expectation set in +@proper[:next_line]+ to
      # +@proper[:this_line]+.
      def transition_lines
        if started?
          @amount_to_change_this = 0
          @amount_to_change_next = 0
          log "Setting @proper[:this_line] = that of :next_line"
          @proper[:this_line] = @proper[:next_line]
          log "Transitioning @proper[:this_line] to #{@proper[:this_line]}"
        else
          if started?
            log "Skipping #transition_lines; checking is stopped."
            return
          end
        end
      end

      # Starts the process of increasing/decreasing line indentation
      # expectations.
      def start
        log "Starting indentation ruling."
        log "Next check should be at #{should_be_at}"
        @started = true
      end

      # Tells if the indentation checking process is on.
      #
      # @return [Boolean] +true+ if it's started; +false+ if not.
      def started?
        @started == true
      end

      # Stops the process of increasing/decreasing line indentation
      # expectations.
      def stop
        if started?
          msg = "Stopping indentation ruling.  Should be: #{should_be_at}; "
          msg << "actual: #{@actual_indentation}"
          log msg
        end

        @started = false
      end

      # Updates +@actual_indentation+ based on the given lexed_line_output.
      #
      # @param [Array] lexed_line_output The lexed output for the current line.
      def update_actual_indentation(lexed_line_output)
        if end_of_multi_line_string?(lexed_line_output)
          log "Found end of multi-line string."
          return
        end

        first_non_space_element = lexed_line_output.find { |e| e[1] != :on_sp }
        @actual_indentation = first_non_space_element.first.last
        log "Actual indentation: #{@actual_indentation}"
      end

      # Determines if the current lexed line is just the end of a tstring.
      #
      # @param [Array] lexed_line_output The lexed output for the current line.
      # @return [Boolean] +true+ if the line contains a +:on_tstring_end+ and
      #   not a +:on_tstring_beg+.
      def end_of_multi_line_string?(lexed_line_output)
        lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
          lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
      end

      # @return [Boolean]
      def valid_line?
        if @actual_indentation != should_be_at
          false
        else
          log "Line is properly indented."
          true
        end
      end

      def comma_update(text_line, lineno, column)
        if column == text_line.length
          log "Line ends with comma."
          @last_comma_statement_line = lineno
        end
      end

      def comment_update(token, lexed_line, file_text, lineno, column)
        # trailing comment?
        if token =~ /\n$/
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

        if not current_lexed_line.only_spaces?
          update_actual_indentation(current_lexed_line)

          unless valid_line?
            @problems << Problem.new(:indentation, lineno, column,
              { actual_indentation: @actual_indentation,
                should_be_at: should_be_at }
            )
          end
        else
          log "Line of only spaces.  Moving on."
          return
        end

        # prep for next line
        @modifier_in_line = nil
        transition_lines
      end

      def kw_update(token, modifier, loop_with_do, lineno)
        if KEYWORDS_TO_INDENT.include?(token)
          log "Indent keyword found: '#{token}'."
          @indent_keyword_line = lineno

          if modifier
            log "Found modifier in line: '#{token}'"
            @modifier_in_line = token
          elsif token == "do" && loop_with_do
            log "Found keyword loop using optional 'do'"
          else
            log "Keyword '#{token}' not used as a modifier."

            if CONTINUATION_KEYWORDS.include? token
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
          if not single_line_indent_statement?(lineno)
            msg = "End of not a single-line statement that needs indenting.  "
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

      def lbracket_update(lineno)
        @bracket_nesting << lineno
        @amount_to_change_next += 1
      end

      def lparen_update(lineno)
        @paren_nesting << lineno
        @amount_to_change_next += 1
      end

      def nl_update(current_lexed_line, lineno, column)
        update_actual_indentation(current_lexed_line)

        if not @op_statement_nesting.empty?
          log "op nesting not empty: #{@op_statement_nesting}"

          if @op_statement_nesting.last + 1 == lineno
            log "End of multi-line op statement."

            if @in_keyword_plus_op
              log "@in_keyword_plus_op: #{@in_keyword_plus_op}"
            else
              @amount_to_change_next -= 1
            end

            @op_statement_nesting.clear
          end
        end

        if !multi_line_braces?(lineno) &&
          !multi_line_brackets?(lineno) &&
          !multi_line_parens?(lineno)
          if @last_comma_statement_line == (lineno - 1)
            log "Last line of multi-line comma statement"
            @last_comma_statement_line = nil

            if @in_keyword_plus_comma
              log "@in_keyword_plus_comma: #{@in_keyword_plus_comma}"
            else
              @amount_to_change_next -= 1
            end
          end
        end

        if @last_period_statement_line == (lineno - 1)
          log "Last line of multi-line period statement"
          @last_period_statement_line = nil

          if @in_keyword_plus_period
            log "@in_keyword_plus_period: #{@in_keyword_plus_period}"
          else
            @amount_to_change_next -= 1
          end
        end

        set_up_line_transition

        unless end_of_multi_line_string?(current_lexed_line)
          unless valid_line?
            @problems << Problem.new(:indentation, lineno, column,
              { actual_indentation: @actual_indentation,
                should_be_at: should_be_at }
            )
          end
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

      # Checks if the statement is a single line statement that needs indenting.
      #
      # @return [Boolean] True if +@indent_keyword_line+ is equal to the
      #   {lineno} (where lineno is the currenly parsed line).
      def single_line_indent_statement?(lineno)
        @indent_keyword_line == lineno
      end

      def multi_line_braces?(lineno)
        if @brace_nesting.empty?
          false
        else
          @brace_nesting.last < lineno
        end
      end

      def multi_line_brackets?(lineno)
        @bracket_nesting.empty? ? false : (@bracket_nesting.last < lineno)
      end

      def multi_line_parens?(lineno)
        @paren_nesting.empty? ? false : (@paren_nesting.last < lineno)
      end

      def in_tstring?
        !@tstring_nesting.empty?
      end

      # @return [Boolean] +true+ if any non-space chars come before the current
      #   'r_' event (+:on_rbrace+, +:on_rbracket+, +:on_rparen+).
      def r_event_without_content?(current_line, lineno, column)
        current_line.first_non_space_element.first == [lineno, column]
      end
    end
  end
end
