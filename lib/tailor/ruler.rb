require 'ripper'
require_relative 'logger'
require_relative 'problem'
require_relative 'ruler/indentation_ruler'
require_relative 'lexed_line'
require_relative 'lexer_constants'


class Tailor

  # https://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/scanner_events
  class Ruler < Ripper::Lexer
    require_relative 'ruler/vertical_whitespace_helpers'

    include LexerConstants
    include VerticalWhitespaceHelpers
    include LogSwitch::Mixin

    attr_reader :indentation_tracker
    attr_accessor :problems

    # @param [String] file The string to lex, or name of the file to read
    #   and analyze.
    def initialize(file, style)
      if File.exists? file
        @file_name = file
        @file_text = File.open(@file_name, 'r').read
      else
        @file_name = "<notafile>"
        @file_text = file
      end

      @problems = []
      @config = style
      log "@config: #{@config}"
      @file_text = ensure_trailing_newline(@file_text)

      @indentation_ruler = IndentationRuler.new(@config[:indentation])
      @indentation_ruler.start

      super @file_text
    end

    def on_backref(token)
      log "BACKREF: '#{token}'"
      super(token)
    end

    def on_backtick(token)
      log "BACKTICK: '#{token}'"
      super(token)
    end

    def on_comma(token)
      log "COMMA: #{token}"
      log "Line length: #{current_line_of_text.length}"

      if column == current_line_of_text.length
        @indentation_ruler.last_comma_statement_line = lineno
      end

      super(token)
    end

    def on_comment(token)
      log "COMMENT: '#{token}'"
      super(token)
    end

    def on_cvar(token)
      log "CVAR: '#{token}'"
      super(token)
    end

    def on_embdoc(token)
      log "EMBDOC: '#{token}'"
      super(token)
    end

    def on_embdoc_beg(token)
      log "EMBDOC_BEG: '#{token}'"
      super(token)
    end

    def on_embdoc_end(token)
      log "EMBDOC_BEG: '#{token}'"
      super(token)
    end

    # Matches the { in an expression embedded in a string.
    def on_embexpr_beg(token)
      log "EMBEXPR_BEG: '#{token}'"
      @embexpr_beg = true
      super(token)
    end

    def on_embexpr_end(token)
      log "EMBEXPR_END: '#{token}'"
      @embexpr_beg = false
      super(token)
    end

    def on_embvar(token)
      log "EMBVAR: '#{token}'"
      super(token)
    end

    # Global variable
    def on_gvar(token)
      log "GVAR: '#{token}'"
      super(token)
    end

    def on_heredoc_beg(token)
      log "HEREDOC_BEG: '#{token}'"
      super(token)
    end

    def on_heredoc_end(token)
      log "HEREDOC_END: '#{token}'"
      super(token)
    end

    def on_ident(token)
      log "IDENT: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a Ruby ignored newline (not sure how this
    # differs from a regular newline).
    #
    # @param [String] token The token that the lexer matched.
    def on_ignored_nl(token)
      log "IGNORED_NL"
      current_line = LexedLine.new(super, lineno)

      if @config[:horizontal_spacing]
        if @config[:horizontal_spacing][:line_length]
          if line_too_long?
            @problems << Problem.new(:line_length, binding)
          end
        end
      end

      @indentation_ruler.stop if @indentation_ruler.tstring_nesting.size > 0

      if current_line.line_ends_with_op?
        log "Line ends with op."

        # Are we nested in a multi-line operation yet?
        if @indentation_ruler.op_statement_nesting.empty?
          @indentation_ruler.op_statement_nesting << lineno

          if current_line.contains_keyword_to_indent?
            @in_keyword_plus_op = true
          else
            log "Increasing :next_line expectation due to multi-line operator statement."
            @indentation_ruler.increase_next_line
          end

        # If this line is a continuation of the last multi-line op statement
        # then update the nesting line number with this line number.
        else
          @indentation_ruler.op_statement_nesting.pop
          @indentation_ruler.op_statement_nesting << lineno
        end
      end

      if @indentation_ruler.op_statement_nesting.empty? &&
        @indentation_ruler.tstring_nesting.empty? &&
        @indentation_ruler.paren_nesting.empty? &&
        @indentation_ruler.brace_nesting.empty? &&
        @indentation_ruler.bracket_nesting.empty?
        if current_line.line_ends_with_comma?
          if @indentation_ruler.last_comma_statement_line.nil?
            @indentation_ruler.increase_next_line
          end

          @indentation_ruler.last_comma_statement_line = lineno
          log "last_comma_statement_line: #{@indentation_ruler.last_comma_statement_line}"
        end
      end

      if current_line.line_ends_with_period?
        if @indentation_ruler.last_period_statement_line.nil?
          @indentation_ruler.increase_next_line
        end

        @indentation_ruler.last_period_statement_line = lineno
        log "last_period_statement_line: #{@indentation_ruler.last_period_statement_line}"
      end

      if not current_line.only_spaces?
        @indentation_ruler.update_actual_indentation(current_line)

        unless @indentation_ruler.valid_line?
          @problems << Problem.new(:indentation, binding)
        end
      else
        log "Line of only spaces.  Moving on."
        return
      end

      # prep for next line
      @indentation_ruler.transition_lines

      super(token)
    end

    # Instance variable
    def on_ivar(token)
      log "IVAR: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a Ruby keyword
    #
    # @param [String] token The token that the lexer matched.
    def on_kw(token)
      log "KW: #{token}"

      if KEYWORDS_TO_INDENT.include?(token)
        log "Indent keyword found: '#{token}'."
        @indent_keyword_line = lineno

        if modifier_keyword?(token)
          log "Found modifier in line: '#{token}'"
        elsif token == "do" && LexedLine.new(super, lineno).loop_with_do?
          log "Found keyword loop using optional 'do'"
        else
          log "Keyword '#{token}' not used as a modifier."

          if CONTINUATION_KEYWORDS.include? token
            log "Continuation keyword: '#{token}'.  Decreasing indent expectation for this line."
            @indentation_ruler.decrease_this_line
          else
            log "Continuation keyword not found: '#{token}'.  Increasing indent expectation for next line."
            @indentation_ruler.increase_next_line
          end
        end
      end

      if token == "end"
        if not single_line_indent_statement?
          log "End of not a single-line statement that needs indenting.  Decrease this line"
          @indentation_ruler.decrease_this_line
        end

        @indentation_ruler.decrease_next_line
      end

      super(token)
    end

    def on_label(token)
      log "LABEL: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a {.  Note a #{ match calls
    # {on_embexpr_beg}.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbrace(token)
      log "LBRACE: '#{token}'"
      @indentation_ruler.brace_nesting << lineno
      @indentation_ruler.increase_next_line
      super(token)
    end

    # Called when the lexer matches a [.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbracket(token)
      log "LBRACKET: '#{token}'"
      @indentation_ruler.bracket_nesting << lineno
      @indentation_ruler.increase_next_line
      super(token)
    end

    def on_lparen(token)
      log "LPAREN: '#{token}'"
      @indentation_ruler.paren_nesting << lineno
      @indentation_ruler.increase_next_line
      super(token)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log "NL"
      current_line = LexedLine.new(super, lineno)
      @indentation_ruler.update_actual_indentation(current_line)

      if @config[:horizontal_spacing]
        if @config[:horizontal_spacing][:line_length]
          if line_too_long?
            @problems << Problem.new(:line_length, binding)
          end
        end
      end

      unless @indentation_ruler.end_of_multiline_string?(current_line)
        unless @indentation_ruler.valid_line?
          @problems << Problem.new(:indentation, binding)
        end
      end

      if not @indentation_ruler.op_statement_nesting.empty?
        log "op nesting not empty: #{@indentation_ruler.op_statement_nesting}"

        if @indentation_ruler.op_statement_nesting.last + 1 == lineno
          log "End of multi-line op statement."
          @indentation_ruler.decrease_this_line
          @indentation_ruler.decrease_next_line unless @in_keyword_plus_op
          @indentation_ruler.op_statement_nesting.clear
        end
      end

      if !multiline_braces? && !multiline_brackets? && !multiline_parens?
        # Last line of multi-line comma statement?
        if @indentation_ruler.last_comma_statement_line == (lineno - 1)
          log "Last line of multi-line comma statement"

          unless current_line.line_ends_with_comma?
            log "Line doesn't end with comma"
            @indentation_ruler.last_comma_statement_line = nil
            @indentation_ruler.decrease_next_line
          end
        end
      end

      if @indentation_ruler.last_period_statement_line == (lineno - 1)
        log "Last line of multi-line period statement"

        unless current_line.line_ends_with_period?
          log "Line doesn't end with period"
          @indentation_ruler.last_period_statement_line = nil
          @indentation_ruler.decrease_next_line
        end
      end

      # prep for next line
      @indentation_ruler.transition_lines

      super(token)
    end

    # Operators
    def on_op(token)
      log "OP: '#{token}'"
      super(token)
    end

    def on_period(token)
      log "PERIOD: '#{token}'"

      if column == current_line_of_text.length
        log "Line length: #{current_line_of_text.length}"
        @indentation_ruler.last_period_statement_line = lineno
      end

      super(token)
    end

    def on_qwords_beg(token)
      log "QWORDS_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a }.
    #
    # @param [String] token The token that the lexer matched.
    def on_rbrace(token)
      log "RBRACE: '#{token}'"

      if multiline_braces?
        log "End of multiline braces!"
        current_line = LexedLine.new(super, lineno)

        if r_event_without_content?(current_line)
          @indentation_ruler.decrease_this_line
        end
      end

      @indentation_ruler.brace_nesting.pop

      # Ripper won't match a closing } in #{} so we have to track if we're
      # inside of one.  If we are, don't decrement then :next_line.
      unless @embexpr_beg
        @indentation_ruler.decrease_next_line
      end

      @embexpr_beg = false
      super(token)
    end

    # Called when the lexer matches a ].
    #
    # @param [String] token The token that the lexer matched.
    def on_rbracket(token)
      log "RBRACKET: '#{token}'"

      if multiline_brackets?
        log "End of multiline brackets!"
        current_line = LexedLine.new(super, lineno)

        if r_event_without_content?(current_line)
          @indentation_ruler.decrease_this_line
        end
      end

      @indentation_ruler.bracket_nesting.pop
      @indentation_ruler.decrease_next_line
      super(token)
    end

    def on_regexp_beg(token)
      log "REGEXP_BEG: '#{token}'"
      super(token)
    end

    def on_regexp_end(token)
      log "REGEXP_END: '#{token}'"
      super(token)
    end

    def on_rparen(token)
      log "RPAREN: '#{token}'"

      if multiline_parens?
        log "End of multiline parens!"
        current_line = LexedLine.new(super, lineno)

        if r_event_without_content?(current_line)
          @indentation_ruler.decrease_this_line
        end
      end

      @indentation_ruler.paren_nesting.pop
      @indentation_ruler.decrease_next_line

      super(token)
    end

    def on_semicolon(token)
      log "SEMICOLON: '#{token}'"
      super(token)
    end

    def on_sp(token)
      log "SP: '#{token}'; size: #{token.size}"

      unless @config[:horizontal_spacing][:allow_hard_tabs]
        if token =~ /\t/
          @problems << Problem.new(:hard_tab, binding)
        end
      end

      super(token)
    end

    def on_symbeg(token)
      log "SYMBEG: '#{token}'"
      super(token)
    end

    def on_tlambda(token)
      log "TLAMBDA: '#{token}'"
      super(token)
    end

    def on_tlambeg(token)
      log "TLAMBEG: '#{token}'"
      super(token)
    end

    def on_tstring_beg(token)
      log "TSTRING_BEG: '#{token}'"
      @indentation_ruler.tstring_nesting << lineno
      super(token)
    end

    def on_tstring_content(token)
      log "TSTRING_CONTENT: '#{token}'"
      super(token)
    end

    def on_tstring_end(token)
      log "TSTRING_END: '#{token}'"
      @indentation_ruler.tstring_nesting.pop
      @indentation_ruler.start unless in_tstring?
      super(token)
    end

    def on_words_beg(token)
      log "WORDS_BEG: '#{token}'"
      super(token)
    end

    def on_words_sep(token)
      log "WORDS_SEP: '#{token}'"
      super(token)
    end

    def on___end__(token)
      log "__END__: '#{token}'"
      super(token)
    end

    def on_CHAR(token)
      log "CHAR: '#{token}'"
      super(token)
    end

    # Checks the current line to see if the given +token+ is being used as a
    # modifier.
    #
    # @return [Boolean] True if there's a modifier in the current line that
    #   is the same type as +token+.
    def modifier_keyword?(token)
      line_of_text = current_line_of_text
      log "Line of text: #{line_of_text}"

      result = catch(:result) do
        sexp_line = Ripper.sexp(line_of_text)

        if sexp_line.nil?
          log "sexp line was nil.  Perhaps that line is part of a multi-line statement?"
          log "Trying again with the last char removed from the line..."
          line_of_text.chop!
          sexp_line = Ripper.sexp(line_of_text)
        end

        if sexp_line.is_a? Array
          log "sexp_line.flatten: #{sexp_line.flatten}"
          log "sexp_line.last.first: #{sexp_line.last.first}"

          begin
            throw(:result, sexp_line.flatten.any? { |s| s == MODIFIERS[token] })
          rescue NoMethodError
          end
        end
      end

      result
    end

    # The current line of text being examined.
    #
    # @return [String] The current line of text.
    def current_line_of_text
      @file_text.split("\n").at(lineno - 1) || ''
    end

    # Checks if the statement is a single line statement that needs indenting.
    #
    # @return [Boolean] True if +@indent_keyword_line+ is equal to the
    #   {lineno} (where lineno is the currenly parsed line).
    def single_line_indent_statement?
      @indent_keyword_line == lineno
    end

    # @return [Boolean] +true+ if any non-space chars come before the current
    #   'r_' event (+:on_rbrace+, +:on_rbracket+, +:on_rparen+).
    def r_event_without_content?(current_line)
      current_line.first_non_space_element.first == [lineno, column]
    end

    def multiline_braces?
      if @indentation_ruler.brace_nesting.empty?
        false
      else
        @indentation_ruler.brace_nesting.last < lineno
      end
    end

    def multiline_brackets?
      @indentation_ruler.bracket_nesting.empty? ? false : (@indentation_ruler.bracket_nesting.last < lineno)
    end

    def multiline_parens?
      @indentation_ruler.paren_nesting.empty? ? false : (@indentation_ruler.paren_nesting.last < lineno)
    end

    def in_tstring?
      !@indentation_ruler.tstring_nesting.empty?
    end

    def line_too_long?
      current_line_of_text.length > @config[:horizontal_spacing][:line_length]
    end

    #---------------------------------------------------------------------------
    # Privates!
    #---------------------------------------------------------------------------
    private

    def log(*args)
      l = begin; lineno; rescue; "<EOF>"; end
      c = begin; column; rescue; "<EOF>"; end
      args.first.insert(0, "<#{self.class}> #{l}[#{c}]: ")
      Tailor::Logger.log(*args)
    end
  end
end
