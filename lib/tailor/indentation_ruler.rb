require_relative 'logger'
require_relative 'lexer_constants'
require_relative 'lexed_line'

class Tailor
  class IndentationRuler
    include LexerConstants

    attr_reader :actual_indentation

    attr_reader :brace_nesting
    attr_reader :bracket_nesting
    attr_reader :op_statement_nesting
    attr_reader :paren_nesting
    attr_reader :tstring_nesting

    attr_accessor :last_comma_statement_line
    attr_accessor :last_period_statement_line

    attr_accessor :amount_to_change_next
    attr_accessor :amount_to_change_this

    def initialize(indentation_config)
      @config = indentation_config

      @proper_indentation = { }
      log "Setting @proper_indentation[:this_line] to 0."
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0
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
      @proper_indentation[:this_line]
    end

    def next_should_be_at
      @proper_indentation[:next_line]
    end

    # Decreases the indentation expectation for the current line by
    # +@config[:spaces]+.
    def decrease_this_line
      if started?
        @proper_indentation[:this_line] -= @config[:spaces]

        if @proper_indentation[:this_line] < 0
          @proper_indentation[:this_line] = 0
        end

        log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
      else
        log "#decrease_this_line called, but checking is stopped."
      end
    end

    # Increases the indentation expectation for the next line by
    # +@config[:spaces]+.
    def increase_next_line
      if started?
        @proper_indentation[:next_line] += @config[:spaces]
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      else
        log "#increase_this_line called, but checking is stopped."
      end
    end

    # Decreases the indentation expectation for the next line by
    # +@config[:spaces]+.
    def decrease_next_line
      if started?
        @proper_indentation[:next_line] -= @config[:spaces]
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      else
        log "#decrease_next_line called, but checking is stopped."
      end
    end

    # Should be called just before moving to the next line.  This sets the
    # expectation set in +@proper_indentation[:next_line]+ to
    # +@proper_indentation[:this_line]+.
    def transition_lines
      if started?
        @amount_to_change_this = 0
        @amount_to_change_next = 0
        log "Setting @proper_indentation[:this_line] = that of :next_line"
        @proper_indentation[:this_line] = @proper_indentation[:next_line]
        log "Transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"
      else
        log "Skipping #transition_lines; checking is stopped." and return if started?
      end
    end

    # Starts the process of increasing/decreasing line indentation
    # expectations.
    def start
      log "Starting indentation ruling.  Next check should be at #{should_be_at}"
      @started = true
    end

    # Tells if the indentation checking process is on.
    #
    # @return [Boolean] +true+ if it's started; +false+ if not.
    def started?
      @started
    end

    # Stops the process of increasing/decreasing line indentation
    # expectations.
    def stop
      if started?
        log "Stopping indentation ruling.  Should be: #{should_be_at}; actual: #{actual_indentation}"
      end

      @started = false
    end

    # Updates +@actual_indentation+ based on the given lexed_line_output.
    #
    # @param [Array] lexed_line_output The lexed output for the current line.
    def update_actual_indentation(lexed_line_output)
      if end_of_multiline_string?(lexed_line_output)
        log "Found end of multiline string."
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
    def end_of_multiline_string?(lexed_line_output)
      lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
        lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
    end

    # @return [Boolean]
    def valid_line?
      if actual_indentation != should_be_at
        false
      else
        log "Line is properly indented."
        true
      end
    end

    def on_comma(current_line_of_text, lineno, column)
      if column == current_line_of_text.length
        last_comma_statement_line = lineno
      end
    end

    def kw_update(token, modifier, loop_with_do, lineno)
      puts "HIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII"
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
            log "Continuation keyword: '#{token}'.  Decreasing indent expectation for this line."
            @amount_to_change_this -= 1
          else
            log "Continuation keyword not found: '#{token}'.  Increasing indent expectation for next line."
            @amount_to_change_next += 1
          end
        end
      end

      if token == "end"
        if not single_line_indent_statement?(lineno)
          log "End of not a single-line statement that needs indenting.  Decrease this line"
          @amount_to_change_this -= 1
        end

        @amount_to_change_next -= 1
      end
    end

    def nl_update
      @modifier_in_line = nil
    end

    # Checks if the statement is a single line statement that needs indenting.
    #
    # @return [Boolean] True if +@indent_keyword_line+ is equal to the
    #   {lineno} (where lineno is the currenly parsed line).
    def single_line_indent_statement?(lineno)
      @indent_keyword_line == lineno
    end

    #---------------------------------------------------------------------------
    # Privates!
    #---------------------------------------------------------------------------
    private

    def log(*args)
      args.first.insert(0, "<#{self.class}> ")
      Tailor::Logger.log(*args)
    end
  end
end
