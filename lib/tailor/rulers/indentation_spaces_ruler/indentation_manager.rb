require_relative '../../ruler'
require_relative '../../logger'
require_relative '../../lexer_constants'

class Tailor
  module Rulers
    class IndentationSpacesRuler < Tailor::Ruler
      class IndentationManager
        include Tailor::LexerConstants
        include Tailor::Logger::Mixin

        OPEN_EVENT_FOR = {
          on_kw: :on_kw,
          on_rbrace: :on_lbrace,
          on_rbracket: :on_lbracket,
          on_rparen: :on_lparen
        }

        attr_accessor :amount_to_change_next
        attr_accessor :amount_to_change_this

        attr_reader :actual_indentation
        attr_reader :indent_reasons
        attr_reader :tstring_nesting

        def initialize(spaces)
          @spaces = spaces

          log "Setting @proper[:this_line] to 0."
          @proper = { this_line: 0, next_line: 0 }
          @actual_indentation = 0

          @indent_reasons = []
          @tstring_nesting = []

          @amount_to_change_this = 0
          start
        end

        # @return [Fixnum] The indent level the file should currently be at.
        def should_be_at
          @proper[:this_line]
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


        # Sets up expectations in +@proper+ based on the number of +/- reasons
        # to change this and next lines, given in +@amount_to_change_this+ and
        # +@amount_to_change_next+, respectively.
        def set_up_line_transition
          log "Amount to change this line: #{@amount_to_change_this}"
          decrease_this_line if @amount_to_change_this < 0
        end

        # Should be called just before moving to the next line.  This sets the
        # expectation set in +@proper[:next_line]+ to
        # +@proper[:this_line]+.
        def transition_lines
          if started?
            log "Resetting change_this to 0."
            @amount_to_change_this = 0
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
            lexed_line.ends_with_period? ||
            lexed_line.ends_with_modifier_kw?
        end

        # Checks to see if the last token in @single_tokens is the same as the
        # one in +token_event+.
        #
        # @param [Array] token_event A single event (probably extracted from a
        #   {LexedLine}).
        # @return [Boolean]
        def line_ends_with_same_as_last(token_event)
          return false if @indent_reasons.empty?

          @indent_reasons.last[:event_type] == token_event[1]
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
          return false if @indent_reasons.empty?

          lexed_line.ends_with_comma? &&
            @indent_reasons.last[:event_type] == :on_lbrace ||
            @indent_reasons.last[:event_type] == :on_lbracket ||
            @indent_reasons.last[:event_type] == :on_lparen
        end

        # Checks if indentation level got increased on this line because of a
        # keyword and if it got increased on this line because of a
        # single-token indenter.
        #
        # @param [Fixnum] lineno
        # @return [Boolean]
        def keyword_and_single_token_line?(lineno)
          d_tokens = @indent_reasons.find_all { |t| t[:lineno] == lineno }
          return false if d_tokens.empty?

          kw_token = d_tokens.reverse.find do |t|
            ['{', '[', '('].none? { |e| t[:token] == e }
          end

          return false if kw_token.nil?

          s_token = @indent_reasons.reverse.find { |t| t[:lineno] == lineno }
          return false unless s_token

          true
        end

        def single_token_start_line
          return if @indent_reasons.empty?

          @indent_reasons.first[:lineno]
        end

        def double_token_start_line
          return if @indent_reasons.empty?

          @indent_reasons.last[:lineno]
        end

        def double_tokens_in_line(lineno)
          @indent_reasons.find_all { |t| t[:lineno] == lineno}
        end

        def add_indent_reason(event_type, token, lineno)
          @indent_reasons << {
            event_type: event_type,
            token: token,
            lineno: lineno,
            should_be_at: @proper[:this_line]
          }

          @proper[:next_line] = @indent_reasons.last[:should_be_at] + @spaces
          log "Added indent reason; it's now:"
          @indent_reasons.each { |r| log r.to_s }
        end

        def update_for_opening_reason(event_type, token, lineno)
          if token.modifier_keyword?
            log "Found modifier in line: '#{token}'"
            return
          end

          log "Token '#{token}' not used as a modifier."

          if token.do_is_for_a_loop?
            log "Found keyword loop using optional 'do'"
            return
          end

          add_indent_reason(event_type, token, lineno)
        end

        def update_for_continuation_reason(token, lexed_line, lineno)
          d_tokens = @indent_reasons.dup
          d_tokens.pop
          on_line_token = d_tokens.find { |t| t[:lineno] == lineno }
          log "online token: #{on_line_token}"

          if on_line_token.nil? && lexed_line.to_s =~ /^\s*#{token}/
            @proper[:this_line] -= @spaces unless @proper[:this_line].zero?
            msg = "Continuation keyword: '#{token}'.  "
            msg << "change_this -= 1 -> #{@proper[:this_line]}"
            log msg
          end

          last_reason_line = @indent_reasons.find { |r| r[:lineno] == lineno }

          if last_reason_line.nil?
            @proper[:next_line] = @indent_reasons.last[:should_be_at] + @spaces
          else
            @proper[:next_line] = @indent_reasons.last[:should_be_at] - @spaces
          end
        end

        def update_for_closing_reason(event_type, lexed_line, lineno)
          remove_continuation_keywords
          remove_appropriate_reason(event_type)

          @proper[:next_line] = if @indent_reasons.empty?
            0
          else
            @indent_reasons.last[:should_be_at] + @spaces
          end

          log "Updated :next after closing; it's now #{@proper[:next_line]}"

          meth = "only_#{event_type.to_s.sub("^on_", '')}?"

          if lexed_line.send(meth.to_sym) || lexed_line.to_s =~ /^\s*end\n?$/
            @proper[:this_line] = @proper[:this_line] - @spaces
            msg = "End multi-line statement. "
            msg < "change_this -= 1 -> #{@proper[:this_line]}."
            log msg
          end
        end

        def remove_appropriate_reason(event_type)
          last_opening_event = @indent_reasons.reverse.find do |r|
            r[:event_type] == OPEN_EVENT_FOR[event_type]
          end

          if last_opening_event
            r_index = @indent_reasons.reverse.index(last_opening_event)
            index = @indent_reasons.size - r_index - 1
            tmp_reasons = []

            @indent_reasons.each_with_index do |r, i|
              tmp_reasons << r unless i == index
            end

            @indent_reasons.replace(tmp_reasons)
          else
            @indent_reasons.pop
          end

          log "Removed indent reason; it's now:"
          @indent_reasons.each { |r| log r.to_s }
        end

        def last_indent_reason_type
          return if @indent_reasons.empty?

          @indent_reasons.last[:event_type]
        end

        def remove_continuation_keywords
          return if @indent_reasons.empty?

          while CONTINUATION_KEYWORDS.include?(@indent_reasons.last[:token])
            @indent_reasons.pop
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

            tokens = @indent_reasons.find_all do |t|
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
