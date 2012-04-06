require_relative '../../ruler'
require_relative '../../logger'
require_relative '../../lexer_constants'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      class IndentationManager
        include Tailor::LexerConstants
        include Tailor::Logger::Mixin

        attr_accessor :amount_to_change_next
        attr_accessor :amount_to_change_this
        attr_accessor :embexpr_beg

        attr_reader :actual_indentation
        attr_reader :double_tokens
        attr_reader :single_tokens
        attr_reader :tstring_nesting

        def initialize(spaces)
          @spaces = spaces

          log "Setting @proper[:this_line] to 0."
          @proper = { this_line: 0, next_line: 0 }
          @actual_indentation = 0

          @double_tokens = []
          @tstring_nesting = []
          @single_tokens = []

          @amount_to_change_next = 0
          @amount_to_change_this = 0
          start
        end

        # @return [Fixnum] The indent level the file should currently be at.
        def should_be_at
          @proper[:this_line]
        end

        def next_should_be_at
          @proper[:next_line]
        end

        # Decreases the indentation expectation for the current line by
        # +@spaces+.
        def decrease_this_line
          if started?
            @proper[:this_line] -= @spaces

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
        # +@spaces+.
        def increase_next_line
          if started?
            @proper[:next_line] += @spaces
            log "@proper[:this_line] = #{@proper[:this_line]}"
            log "@proper[:next_line] = #{@proper[:next_line]}"
          else
            log "#increase_this_line called, but checking is stopped."
          end
        end

        # Decreases the indentation expectation for the next line by
        # +@spaces+.
        def decrease_next_line
          if started?
            @proper[:next_line] -= @spaces
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

        def single_token_indent_line_end?(lexed_line)
          lexed_line.ends_with_op? ||
            lexed_line.ends_with_comma? ||
            lexed_line.ends_with_period?
        end

        def line_ends_with_same_as_last(token_event)
          return false if @single_tokens.empty?

          @single_tokens.last[:token] == token_event.last
        end

        def comma_is_part_of_enclosed_statement?(lexed_line, lineno)
          lexed_line.ends_with_comma? &&
            continuing_enclosed_statement?(lineno)
        end

        def keyword_and_single_token_line?(lineno)
          d_tokens = @double_tokens.find_all { |t| t[:lineno] == lineno }
          return false if d_tokens.empty?

          kw_token = d_tokens.reverse.find do |t|
            ['{', '[', '('].none? { |e| t[:token] == e }
          end

          return false if kw_token.nil?

          s_token = @single_tokens.reverse.find { |t| t[:lineno] == lineno }
          return false unless s_token

          true
        end

        def single_token_start_line
          return if @single_tokens.empty?

          @single_tokens.first[:lineno]
        end

        def double_token_start_line
          return if @double_tokens.empty?

          @double_tokens.last[:lineno]
        end

        def in_a_nested_statement?
          !@single_tokens.empty? ||
          !@double_tokens.empty?
        end

        def continuing_enclosed_statement?(lineno)
          multi_line_braces?(lineno) ||
          multi_line_brackets?(lineno) ||
          multi_line_parens?(lineno)
        end

        def update_for_opening_double_token(token, lineno)
          if token.modifier_keyword?
            log "Found modifier in line: '#{token}'"
            return
          end

          if token.do_is_for_a_loop?
            log "Found keyword loop using optional 'do'"
            return
          end

          log "Keyword '#{token}' not used as a modifier."
          @double_tokens << { token: token, lineno: lineno }

          if token.continuation_keyword?
            @amount_to_change_this -= 1
            msg = "Continuation keyword: '#{token}'.  "
            msg << "change_this -= 1 -> #{@amount_to_change_this}"
            log msg
            return
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

          remove_continuation_keywords

          @double_tokens.pop
        end

        def remove_continuation_keywords
          return if @double_tokens.empty?

          while CONTINUATION_KEYWORDS.include?(@double_tokens.last[:token])
            @double_tokens.pop
          end
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
