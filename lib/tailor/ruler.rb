require 'ripper'
require_relative 'logger'
require_relative 'lexer_constants'
require_relative 'problem'


class Tailor

  # https://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/scanner_events
  # https://github.com/ruby/ruby/blob/trunk/ext/ripper/eventids2.c
  class Ruler < Ripper::Lexer
    include Tailor::LexerConstants
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

      log "<#{self.class}> Setting @proper_indentation[:this_line] to 0."
      @proper_indentation = {}
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0
      @brace_nesting = []
      @bracket_nesting = []
      @paren_nesting = []
      @op_statement_nesting = []

      super @file_text
    end

    # Counts the number of newlines at the end of the file.
    #
    # @param [String] text The file's text.
    # @return [Fixnum] The number of \n at the end of the file.
    def count_trailing_newlines(text)
      if text.end_with? "\n"
        count = 0

        text.reverse.chars do |c|
          if c == "\n"
            count += 1
          else
            break
          end
        end

        count
      else
        0
      end
    end

    # Checks to see if the file's final character is a \n.  If it is, it just
    # returns the text that was passed in.  If it's not, it adds a \n, since
    # the current indentation-checking algorithm only checks indent levels when
    # it parses a newline character (without this, indentation problems on the
    # final line won't ever get caught).
    #
    # @param [String] text The file's text.
    # @return [String] The file's text with a \n if there wasn't one there
    #   already.
    def ensure_trailing_newline(text)
      trailing_newline_count = count_trailing_newlines(text)

      if trailing_newline_count != @config[:vertical_whitespace][:trailing_newlines]
        lineno = "<EOF>"
        column = "<EOF>"
        @problems << Problem.new(:trailing_newlines, binding)
        log "ERROR: Trailing Newlines.  #{@problems.last[:message]}"
      end

      trailing_newline_count > 0 ? text : (text + "\n")
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
      log "embexpr_beg, token '#{token}'"
      @embexpr_beg = true
      super(token)
    end

    def on_embexpr_end(token)
      log "embexpr_end: token: '#{token}'"
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
      log "ignored_nl."

      # check indentation
      c = current_lex(super)

      if not line_of_only_spaces?(c)
        indentation = current_line_indent(c)
        log "indentation: #{indentation}"

        if indentation != @proper_indentation[:this_line]
          @problems << Problem.new(:indentation, binding)
          log "ERROR: Indentation.  #{@problems.last[:message]}"
        end
      else
        log "Line of only spaces.  Moving on."
        return
      end

      if line_ends_with_op?(c)
        # Are we nested in a multi-line operation yet?
        if @op_statement_nesting.empty?
          @op_statement_nesting << lineno
        end

        # If this line is a continuation of the last multi-line op statement
        # then update the nesting line number with this line number.
        if @op_statement_nesting.last + 1 == lineno
          @op_statement_nesting.pop
          @op_statement_nesting << lineno
        else
          log "Increasing :next_line expectation due to multi-line operator statement."
          @proper_indentation[:next_line] += @config[:indentation][:spaces]
          log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
        end
      end

      # prep for next line
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"

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
      log "kw. token: #{token}"

      if KEYWORDS_TO_INDENT.include?(token)
        c = current_lex(super)

        if modifier_keyword?(token)
          log "Found modifier in line"
        else
          log "Modifier NOT in line"
          update_indentation_expectations(token)
        end
      end

      if token == "end"
        update_outdentation_expectations
      end

      log "@proper_indentation[:this_line]: #{@proper_indentation[:this_line]}"
      log "@proper_indentation[:next_line]: #{@proper_indentation[:next_line]}"

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
      log "lbrace"
      @brace_nesting << lineno
      @proper_indentation[:next_line] += @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    # Called when the lexer matches a [.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbracket(token)
      log "lbracket"
      @bracket_nesting << lineno
      @proper_indentation[:next_line] += @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def on_lparen(token)
      log "LPAREN: '#{token}'"
      @paren_nesting << lineno
      @proper_indentation[:next_line] += @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log "NL"

      c = current_lex(super)

      # check indentation
      indentation = current_line_indent(c)

      if indentation != @proper_indentation[:this_line]
        @problems << Problem.new(:indentation, binding)
        log "ERROR: Indentation.  #{@problems.last[:message]}"
      end

      unless @op_statement_nesting.empty?
        if @op_statement_nesting.last + 1 == lineno
          log "End of multi-line op statement."
          @proper_indentation[:this_line] -= @config[:indentation][:spaces]
        end
      end

        # prep for next line
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"

      super(token)
    end

    # Operators
    def on_op(token)
      log "OP: '#{token}'; column: #{column}"
      super(token)
    end

    def on_period(token)
      log "PERIOD: '#{token}'"
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
      log "rbrace"

      if multiline_braces?
        log "multiline braces!"
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]
      end

      @brace_nesting.pop

      # Ripper won't match a closing } in #{} so we have to track if we're
      # inside of one.  If we are, don't decrement then :next_line.
      unless @embexpr_beg
        @proper_indentation[:next_line] -= @config[:indentation][:spaces]
      end

      @embexpr_beg = false
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    # Called when the lexer matches a ].
    #
    # @param [String] token The token that the lexer matched.
    def on_rbracket(token)
      log "RBRACKET: '#{token}'"

      if multiline_brackets?
        log "multiline brackets!"
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]
      end

      @bracket_nesting.pop

      @proper_indentation[:next_line] -= @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
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
        log "end of multiline parens!"
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]
        log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
      end

      @paren_nesting.pop

      @proper_indentation[:next_line] -= @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def on_semicolon(token)
      log "SEMICOLON: '#{token}'"
      super(token)
    end

    def on_sp(token)
      log "SP: '#{token}'; size: #{token.size}; column: #{column}"
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
      super(token)
    end

    def on_tstring_content(token)
      log "TSTRING_CONTENT: '#{token}'"
      super(token)
    end

    def on_tstring_end(token)
      log "TSTRING_END: '#{token}'"
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

    # @param [Array] lexed_output The lexed output for the whole file.
    # @return [Array]
    def current_lex(lexed_output)
      lexed_output.find_all { |token| token.first.first == lineno }
    end

    # @return [Fixnum] Number of the first non-space (:on_sp) token.
    def current_line_indent(lexed_line_output)
      first_non_space_element = lexed_line_output.find { |e| e[1] != :on_sp }
      first_non_space_element.first.last
    end

    # Looks at the +lexed_line_output+ and determines if it' s a line of just
    # space characters: spaces, newlines.
    #
    # @param [Array] lexed_line_output
    # @return [Boolean]
    def line_of_only_spaces?(lexed_line_output)
      first_non_space_element = lexed_line_output.find do |e|
        e[1] != (:on_sp && :on_nl && :on_ignored_nl)
      end

      log "first non-space element '#{first_non_space_element}'"

      if first_non_space_element.nil? || first_non_space_element.empty?
        true
      else
        false
      end
    end

    # Checks the current line to see if the given +token+ is being used as a
    # modifier.
    #
    # @return [Boolean] True if there's a modifier in the current line that
    #   is the same type as +token+.
    def modifier_keyword?(token)
      line_of_text = current_line_of_text
      log "line of text: #{line_of_text}"

      sexp_line = Ripper.sexp(line_of_text)
      log "sexp line: #{sexp_line}"
      log "sexp line[1]: #{sexp_line[1]}" unless sexp_line.nil?

      if sexp_line.is_a? Array
        log "as string: #{sexp_line.flatten}"
        log "last first: #{sexp_line.last.first}"

        begin
          result = sexp_line.last.first.any? { |s| s == MODIFIERS[token] }
          log "result = #{result}"
        rescue NoMethodError
        end
      end

      result
    end

    # The current line of text being examined.
    #
    # @return [String] The current line of text.
    def current_line_of_text
      @file_text.split("\n").at(lineno - 1)
    end

    # Updates the values used for detecting the proper number of indentation
    # spaces.  Should be called when reaching the end of a line.
    def update_outdentation_expectations
      log "outdent keyword found: end"

      unless single_line_indent_statement?
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]

        if @proper_indentation[:this_line] < 0
          @proper_indentation[:this_line] = 0
        end
      end

      @proper_indentation[:next_line] -= @config[:indentation][:spaces]
    end

    # Updates the values used for detecting the proper number of indentation
    # spaces.  Should be called when reaching the end of a line.
    #
    # @param [String] token The token that got matched in the line.  Used to
    #   determine proper indentation levels.
    def update_indentation_expectations(token)
      if KEYWORDS_TO_INDENT.include? token
        log "Updating indent expectation due to keyword found: '#{token}'."
        @indent_keyword_line = lineno
      else
        log "Not sure why updating indentation expectation..."
      end

      if CONTINUATION_KEYWORDS.include? token
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]

        if @proper_indentation[:this_line] < 0
          @proper_indentation[:this_line] = 0
        end
      else
        @proper_indentation[:next_line] += @config[:indentation][:spaces]
      end
    end

    # Checks if the statement is a single line statement that needs indenting.
    #
    # @return [Boolean] True if +@indent_keyword_line+ is equal to the
    #   {lineno} (where lineno is the currenly parsed line).
    def single_line_indent_statement?
      @indent_keyword_line == lineno
    end

    # Checks to see if the current line ends with an operator (not counting the
    # newline that might come after it).
    #
    # @param [Array] lexed_line_output The lexed output of the current line.
    # @return [Boolean] true if the line ends with an operator; false if not.
    def line_ends_with_op?(lexed_line_output)
      tokens_in_line = lexed_line_output.map { |e| e[1] }

      until tokens_in_line.last != (:on_ignored_nl || :on_nl)
        tokens_in_line.pop
        lexed_line_output.pop
      end

      if MULTILINE_OPERATORS.include?(lexed_line_output.last.last) &&
        tokens_in_line.last == :on_op
        true
      else
        false
      end
    end

    def multiline_braces?
      @brace_nesting.empty? ? false : (@brace_nesting.last < lineno)
    end

    def multiline_brackets?
      @bracket_nesting.empty? ? false : (@bracket_nesting.last < lineno)
    end

    def multiline_parens?
      @paren_nesting.empty? ? false : (@paren_nesting.last < lineno)
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
