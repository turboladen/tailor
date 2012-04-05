require_relative '../../ruler'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      module IndentationHelpers

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
            @amount_to_change_this = 0
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
          unless valid_line?
            @problems << Problem.new(:indentation, lineno, column,
              { actual_indentation: @actual_indentation,
                should_be_at: should_be_at }
            )
          end
        end

        def update_for_period_statement(lineno)
          if @last_period_statement_line == (lineno - 1)
            log "Last line of multi-line period statement"
            @last_period_statement_line = nil

            if @in_keyword_plus_period
              log "@in_keyword_plus_period: #{@in_keyword_plus_period}"
            else
              @amount_to_change_next -= 1
            end
          end
        end

        def update_for_comma_statement(lineno)
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

        def update_for_op_statement(lineno)
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
end
