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

        # Sets up expectations in +@proper+ based on the number of +/- reasons
        # to change this and next lines, given in +@amount_to_change_this+ and
        # +@amount_to_change_next+, respectively.
        def set_up_line_transition
          log "Amount to change next line: #{@amount_to_change_next}"
          log "Amount to change this line: #{@amount_to_change_this}"

          if @amount_to_change_next > 0
            increase_next_line
          elsif @amount_to_change_next < 0
            decrease_next_line
          end

          decrease_next_line if @amount_to_change_next <= -2
          decrease_this_line if @amount_to_change_this < 0
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

        # Checks if the current line ends with an operator, comma, or period.
        #
        # @param [LexedLine] lexed_line
        # @return [Boolean]
        def line_ends_with_single_token_indenter?(lexed_line)
          lexed_line.ends_with_op? ||
            lexed_line.ends_with_comma? ||
            lexed_line.ends_with_period?
        end

        # Checks to see if the last token in @single_tokens is the same as the
        # one in +token_event+.
        #
        # @param [Array] token_event A single event (probably extracted from a
        #   {LexedLine}).
        # @return [Boolean]
        def line_ends_with_same_as_last(token_event)
          return false if @single_tokens.empty?

          @single_tokens.last[:token] == token_event.last
        end

        # Checks to see if +lexed_line+ ends with a comma, and if it is in the
        # middle of an enclosed statement (unclosed braces, brackets, parens).
        # You don't want to update indentation expectations for this comma if
        # you've already done so for the start of the enclosed statement.
        #
        # @param [LexedLine] lexed_line
        # @param [Fixnum] lineno
        # @return [Boolean]
        def comma_is_part_of_enclosed_statement?(lexed_line, lineno)
          lexed_line.ends_with_comma? &&
            continuing_enclosed_statement?(lineno)
        end

        # Checks if indentation level got increased on this line because of a
        # keyword and if it got increased on this line because of a
        # single-token indenter.
        #
        # @param [Fixnum] lineno
        # @return [Boolean]
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
            @amount_to_change_this -= 1
            msg = "End of not a single-line statement that needs indenting."
            msg < "change_this -= 1 -> #{@amount_to_change_this}."
            log msg
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

        # Overriding to be able to call #multi_line_brackets?,
        # #multi_line_braces?, and #multi_line_parens?, where each takes a
        # single parameter, which is the lineno.
        #
        # @return [Boolean]
        def method_missing(meth, *args, &blk)
          if meth.to_s =~ /^multi_line_(.+)\?$/
            token = case $1
            when "brackets" then '['
            when "braces" then '{'
            when "parens" then '('
            else
              super(meth, *args, &blk)
            end

            lineno = args.first

            tokens = @double_tokens.find_all do |t|
              t[:token] == token
            end

            return false if tokens.empty?

            token_on_this_line = tokens.find { |t| t[:lineno] == lineno }
            return true if token_on_this_line.nil?

            false
          else
            super(meth, *args, &blk)
          end
        end

        def in_tstring?
          !@tstring_nesting.empty?
        end
      end
    end
  end
end