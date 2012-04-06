require_relative '../../ruler'
require_relative '../../logger'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      module IndentationHelpers
        include Tailor::Logger::Mixin

        # @return [Fixnum] The indent level the file should currently be at.
        def should_be_at
          @proper[:this_line]
        end

        def next_should_be_at
          @proper[:next_line]
        end

        # Decreases the indentation expectation for the current line by
        # +@config+.
        def decrease_this_line
          if started?
            @proper[:this_line] -= @config

            if @proper[:this_line] < 0
              @proper[:this_line] = 0
            end

            log "@proper[:this_line] = #{@proper[:this_line]}"
            log "@proper[:next_line] = #{@proper[:next_line]}"
          else
            log "#decrease_this_line called, but checking is stopped."
          end
        end

        # Increases the indentation expectation for the next line by
        # +@config+.
        def increase_next_line
          if started?
            @proper[:next_line] += @config
            log "@proper[:this_line] = #{@proper[:this_line]}"
            log "@proper[:next_line] = #{@proper[:next_line]}"
          else
            log "#increase_this_line called, but checking is stopped."
          end
        end

        # Decreases the indentation expectation for the next line by
        # +@config+.
        def decrease_next_line
          if started?
            @proper[:next_line] -= @config
            log "@proper[:this_line] = #{@proper[:this_line]}"
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
            log "Resetting change_this to 0."
            @amount_to_change_this = 0
            log "Resetting change_next to 0."
            @amount_to_change_next = 0
            log "Setting @proper[:this_line] = that of :next_line"
            @proper[:this_line] = @proper[:next_line]
            log "Transitioning @proper[:this_line] to #{@proper[:this_line]}"
          else
            log "Skipping #transition_lines; checking is stopped."
          end
        end

        # Starts the process of increasing/decreasing line indentation
        # expectations.
        def start
          log "Starting indentation ruling."
          log "Next check should be at #{should_be_at}"
          @do_measurement = true
        end

        # Tells if the indentation checking process is on.
        #
        # @return [Boolean] +true+ if it's started; +false+ if not.
        def started?
          @do_measurement
        end

        # Stops the process of increasing/decreasing line indentation
        # expectations.
        def stop
          if started?
            msg = "Stopping indentation ruling.  Should be: #{should_be_at}; "
            msg << "actual: #{@actual_indentation}"
            log msg
          end

          @do_measurement = false
        end

        # Updates +@actual_indentation+ based on the given lexed_line_output.
        #
        # @param [Array] lexed_line_output The lexed output for the current line.
        def update_actual_indentation(lexed_line_output)
          if lexed_line_output.end_of_multi_line_string?
            log "Found end of multi-line string."
            return
          end

          first_non_space_element = lexed_line_output.first_non_space_element
          @actual_indentation = first_non_space_element.first.last
          log "Actual indentation: #{@actual_indentation}"
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

        # Checks if the line's indentation level is appropriate.
        #
        # @param [Fixnum] lineno The line the potential problem is on.
        # @param [Fixnum] column The column the potential problem is on.
        def measure(lineno, column)
          log "Measuring..."

          unless valid_line?
            @problems << Problem.new(:indentation, lineno, column,
              { actual_indentation: @actual_indentation,
                should_be_at: should_be_at }
            )
          end
        end

        def update_for_start_of_op_statement(current_lexed_line, lineno)
          log "Line ends with op."

          # Are we nested in a multi-line operation yet?
          if @op_statement_nesting.empty?
            @op_statement_nesting << lineno

            if current_lexed_line.contains_keyword_to_indent? &&
              @modifier_in_line.nil?
              @in_keyword_plus_op = true
            else
              @amount_to_change_next += 1
              msg = "Multi-line op statement: "
              msg << "change_next += 1 -> #{@amount_to_change_next}"
              log msg
            end

            # If this line is a continuation of the last multi-line op statement
            # then update the nesting line number with this line number.
          else
            @op_statement_nesting.pop
            @op_statement_nesting << lineno
          end
        end

        def update_for_start_of_comma_statement(current_lexed_line, lineno)
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

        def update_for_start_of_period_statement(current_lexed_line, lineno)
          if current_lexed_line.contains_keyword_to_indent? &&
            @modifier_in_line.nil?
            @in_keyword_plus_period = true
          elsif @last_period_statement_line.nil?
            @amount_to_change_next += 1
            msg = "Increasing :next_line expectation due to "
            msg << "multi-line period statement."
            log msg
          end

          @last_period_statement_line = lineno
          log "last_period_statement_line: #{@last_period_statement_line}"
        end

        def update_for_end_of_period_statement(lineno)
          if @last_period_statement_line == (lineno - 1)
            log "Last line of multi-line period statement"
            @last_period_statement_line = nil

            if @in_keyword_plus_period
              log "@in_keyword_plus_period: #{@in_keyword_plus_period}"
            else
              @amount_to_change_next -= 1
              msg = "End of period statement. "
              msg << "change_next -= 1 -> #{@amount_to_change_next}"
              log msg
            end
          end
        end

        def update_for_end_of_comma_statement(lineno)
          if @last_comma_statement_line == (lineno - 1)
            log "Last line of multi-line comma statement"
            @last_comma_statement_line = nil

            if @in_keyword_plus_comma
              log "@in_keyword_plus_comma: #{@in_keyword_plus_comma}"
            else
              @amount_to_change_next -= 1
              msg = "End of comma statement. "
              msg << "change_next -= 1 -> #{@amount_to_change_next}"
              log msg
            end
          end
        end

        def update_for_end_of_op_statement(lineno)
          if @op_statement_nesting.last + 1 == lineno
            log "End of multi-line op statement."

            if @in_keyword_plus_op
              log "@in_keyword_plus_op: #{@in_keyword_plus_op}"
            else
              @amount_to_change_next -= 1
              msg = "End of op statement. "
              msg << "change_next -= 1 -> #{@amount_to_change_next}"
              log msg
            end

            @op_statement_nesting.clear
          end
        end

        def in_a_nested_statement?
          !@op_statement_nesting.empty? ||
          !@tstring_nesting.empty? ||
          !@double_tokens.empty?
        end

        def continuing_enclosed_statement?(lineno)
          multi_line_braces?(lineno) ||
          multi_line_brackets?(lineno) ||
          multi_line_parens?(lineno)
        end

        def reset_keyword_state
          log "Resetting keyword state variables."
          @modifier_in_line = nil
          @in_keyword_plus_op = false
          @in_keyword_plus_comma = false
          @in_keyword_plus_period = false
        end

        def update_for_opening_double_token(token, lineno)
          @double_tokens << { token: token, lineno: lineno }

          if token.keyword_to_indent?
            if token.modifier_keyword?
              log "Found modifier in line: '#{token}'"
              @modifier_in_line = token
              return
            end

            if token.do_is_for_a_loop?
              log "Found keyword loop using optional 'do'"
              return
            end

            log "Keyword '#{token}' not used as a modifier."

            if token.continuation_keyword?
              msg = "Continuation keyword: '#{token}'.  "
              msg << "Decreasing indent expectation for this line."
              log msg
              @amount_to_change_this -= 1
              return
            end
          end

          @amount_to_change_next += 1
          msg = "double-token statement opening: "
          msg << "change_next += 1 -> #{@amount_to_change_next}"
          log msg
        end

        def update_for_closing_double_token(event_type, lexed_line)
          meth = "only_#{event_type}?"

          if lexed_line.send(meth.to_sym)
            msg = "End of not a single-line statement that needs indenting."
            msg < "Decrease this line."
            log msg
            @amount_to_change_this -= 1
          end

          if event_type == :rbrace && @embexpr_beg == true
            msg = "Got :rbrace and @embexpr_beg is true. "
            msg << " Must be at an @embexpr_end."
            log msg
            @embexpr_beg = false
            return
          end

          @amount_to_change_next -= 1
          msg = "double-token statement closing: "
          msg << "change_next -= 1 -> #{@amount_to_change_next}"
          log msg

          @double_tokens.pop
        end

        def multi_line_braces?(lineno)
          @double_tokens.reverse.find do |t|
            t[:token] == '{' && t[:lineno] < lineno
          end
        end

        def multi_line_brackets?(lineno)
          @double_tokens.reverse.find do |t|
            t[:token] == '[' && t[:lineno] < lineno
          end
        end

        def multi_line_parens?(lineno)
          @double_tokens.reverse.find do |t|
            t[:token] == '(' && t[:lineno] < lineno
          end
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
end
