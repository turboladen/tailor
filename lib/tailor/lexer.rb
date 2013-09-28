require 'ripper'
require_relative 'composite_observable'
require_relative 'lexed_line'
require_relative 'lexer/lexer_constants'
require_relative 'logger'
require_relative 'lexer/token'


class Tailor

  # This is what provides the main file parsing for tailor.  For every event
  # that's encountered, it calls the appropriate notifier method.  Notifier
  # methods are provided by {Tailor::CompositeObservable}.
  class Lexer < Ripper::Lexer
    include CompositeObservable
    include LexerConstants
    include LogSwitch::Mixin

    # @param [String] file The string to lex, or name of the file to read
    #   and analyze.
    def initialize(file)
      @original_file_text = if File.exists? file
        @file_name = file
        File.open(@file_name, 'r').read
      else
        @file_name = '<notafile>'
        file
      end

      @file_text = ensure_trailing_newline(@original_file_text)
      @file_text = sub_line_ending_backslashes(@file_text)
      super @file_text
      @added_newline = @file_text != @original_file_text
    end

    # This kicks off the process of parsing the file and publishing events
    # as the events are discovered.
    def lex
      file_beg_changed
      notify_file_beg_observers(@file_name)

      super

      file_end_changed
      notify_file_end_observers(count_trailing_newlines(@original_file_text))
    end

    def on_backref(token)
      log "BACKREF: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the first ` in a `` statement (the second
    # matches :on_tstring_end; this may or may not be a Ruby bug).
    #
    # @param [String] token The token that the lexer matched.
    def on_backtick(token)
      log "BACKTICK: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a comma.
    #
    # @param [String] token The token that the lexer matched.
    def on_comma(token)
      log "COMMA: #{token}"
      log "Line length: #{current_line_of_text.length}"

      comma_changed
      notify_comma_observers(current_line_of_text, lineno, column)

      super(token)
    end

    # Called when the lexer matches a #.  The token includes the # as well as
    # the content after it.
    #
    # @param [String] token The token that the lexer matched.
    def on_comment(token)
      log "COMMENT: '#{token}'"

      l_token = Tailor::Lexer::Token.new(token)
      lexed_line = LexedLine.new(super, lineno)
      comment_changed
      notify_comment_observers(l_token, lexed_line, @file_text, lineno, column)

      super(token)
    end

    # Called when the lexer matches a constant (including class names, of
    # course).
    #
    # @param [String] token The token that the lexer matched.
    def on_const(token)
      log "CONST: '#{token}'"

      l_token = Tailor::Lexer::Token.new(token)
      lexed_line = LexedLine.new(super, lineno)
      const_changed
      notify_const_observers(l_token, lexed_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches a class variable.
    #
    # @param [String] token The token that the lexer matched.
    def on_cvar(token)
      log "CVAR: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the content inside a =begin/=end.
    #
    # @param [String] token The token that the lexer matched.
    def on_embdoc(token)
      log "EMBDOC: '#{token}'"
      super(token)
    end

    # Called when the lexer matches =begin.
    #
    # @param [String] token The token that the lexer matched.
    def on_embdoc_beg(token)
      log "EMBDOC_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches =end.
    #
    # @param [String] token The token that the lexer matched.
    def on_embdoc_end(token)
      log "EMBDOC_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a #{.
    #
    # @param [String] token The token that the lexer matched.
    def on_embexpr_beg(token)
      log "EMBEXPR_BEG: '#{token}'"
      current_line = LexedLine.new(super, lineno)
      embexpr_beg_changed
      notify_embexpr_beg_observers(current_line, lineno, column)
      super(token)
    end

    # Called when the lexer matches the } that closes a #{.  Note that as of
    # MRI 1.9.3-p125, this never gets called.  Logged as a bug and fixed in
    # ruby 2.0.0-p0: https://bugs.ruby-lang.org/issues/6211.
    #
    # @param [String] token The token that the lexer matched.
    def on_embexpr_end(token)
      log "EMBEXPR_END: '#{token}'"
      current_line = LexedLine.new(super, lineno)
      embexpr_end_changed
      notify_embexpr_end_observers(current_line, lineno, column)
      super(token)
    end

    def on_embvar(token)
      log "EMBVAR: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a Float.
    #
    # @param [String] token The token that the lexer matched.
    def on_float(token)
      log "FLOAT: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a global variable.
    #
    # @param [String] token The token that the lexer matched.
    def on_gvar(token)
      log "GVAR: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the beginning of a heredoc.
    #
    # @param [String] token The token that the lexer matched.
    def on_heredoc_beg(token)
      log "HEREDOC_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the end of a heredoc.
    #
    # @param [String] token The token that the lexer matched.
    def on_heredoc_end(token)
      log "HEREDOC_END: '#{token}'"
      super(token)
    end

    # Called when the lexer matches an identifier (method name, variable, the
    # text part of a Symbol, etc.).
    #
    # @param [String] token The token that the lexer matched.
    def on_ident(token)
      log "IDENT: '#{token}'"
      l_token = Tailor::Lexer::Token.new(token)
      lexed_line = LexedLine.new(super, lineno)
      ident_changed
      notify_ident_observers(l_token, lexed_line, lineno, column)
      super(token)
    end

    # Called when the lexer matches a Ruby ignored newline.  Ignored newlines
    # occur when a newline is encountered, but the statement that was expressed
    # on that line was not completed on that line.
    #
    # @param [String] token The token that the lexer matched.
    def on_ignored_nl(token)
      log 'IGNORED_NL'

      current_line = LexedLine.new(super, lineno)
      ignored_nl_changed
      notify_ignored_nl_observers(current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches an Integer.
    #
    # @param [String] token The token that the lexer matched.
    def on_int(token)
      log "INT: '#{token}'"
      super(token)
    end

    # Called when the lexer matches an instance variable.
    #
    # @param [String] token The token that the lexer matched.
    def on_ivar(token)
      log "IVAR: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a Ruby keyword.
    #
    # @param [String] token The token that the lexer matched.
    def on_kw(token)
      log "KW: #{token}"
      current_line = LexedLine.new(super, lineno)

      l_token = Tailor::Lexer::Token.new(token,
        {
          loop_with_do: current_line.loop_with_do?,
          full_line_of_text: current_line_of_text
        }
      )

      kw_changed
      notify_kw_observers(l_token, current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches a label (the first part in a non-rocket
    # style Hash).
    #
    # Example:
    #   one: 1     # Matches one:
    #
    # @param [String] token The token that the lexer matched.
    def on_label(token)
      log "LABEL: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a {.  Note a #{ match calls
    # +#on_embexpr_beg+.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbrace(token)
      log "LBRACE: '#{token}'"
      current_line = LexedLine.new(super, lineno)
      lbrace_changed
      notify_lbrace_observers(current_line, lineno, column)
      super(token)
    end

    # Called when the lexer matches a [.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbracket(token)
      log "LBRACKET: '#{token}'"
      current_line = LexedLine.new(super, lineno)
      lbracket_changed
      notify_lbracket_observers(current_line, lineno, column)
      super(token)
    end

    # Called when the lexer matches a (.
    #
    # @param [String] token The token that the lexer matched.
    def on_lparen(token)
      log "LPAREN: '#{token}'"
      lparen_changed
      notify_lparen_observers(lineno, column)
      super(token)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log 'NL'
      current_line = LexedLine.new(super, lineno)

      nl_changed
      notify_nl_observers(current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches an operator.
    #
    # @param [String] token The token that the lexer matched.
    def on_op(token)
      log "OP: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a period.
    #
    # @param [String] token The token that the lexer matched.
    def on_period(token)
      log "PERIOD: '#{token}'"

      period_changed
      notify_period_observers(current_line_of_text.length, lineno, column)

      super(token)
    end

    # Called when the lexer matches '%w'.  Statement is ended by a
    # +:on_words_end+.
    #
    # @param [String] token The token that the lexer matched.
    def on_qwords_beg(token)
      log "QWORDS_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a }.
    #
    # @param [String] token The token that the lexer matched.
    def on_rbrace(token)
      log "RBRACE: '#{token}'"

      current_line = LexedLine.new(super, lineno)
      rbrace_changed
      notify_rbrace_observers(current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches a ].
    #
    # @param [String] token The token that the lexer matched.
    def on_rbracket(token)
      log "RBRACKET: '#{token}'"

      current_line = LexedLine.new(super, lineno)
      rbracket_changed
      notify_rbracket_observers(current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches the beginning of a Regexp.
    #
    # @param [String] token The token that the lexer matched.
    def on_regexp_beg(token)
      log "REGEXP_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the end of a Regexp.
    #
    # @param [String] token The token that the lexer matched.
    def on_regexp_end(token)
      log "REGEXP_END: '#{token}'"
      super(token)
    end

    # Called when the lexer matches a ).
    #
    # @param [String] token The token that the lexer matched.
    def on_rparen(token)
      log "RPAREN: '#{token}'"

      current_line = LexedLine.new(super, lineno)
      rparen_changed
      notify_rparen_observers(current_line, lineno, column)

      super(token)
    end

    # Called when the lexer matches a ;.
    #
    # @param [String] token The token that the lexer matched.
    def on_semicolon(token)
      log "SEMICOLON: '#{token}'"
      super(token)
    end

    # Called when the lexer matches any type of space character.
    #
    # @param [String] token The token that the lexer matched.
    def on_sp(token)
      log "SP: '#{token}'; size: #{token.size}"
      l_token = Tailor::Lexer::Token.new(token)
      sp_changed
      notify_sp_observers(l_token, lineno, column)

      # Deal with lines that end with \
      if token == "\\\n"
        current_line = LexedLine.new(super, lineno)
        ignored_nl_changed
        notify_ignored_nl_observers(current_line, lineno, column)
      end
      super(token)
    end

    # Called when the lexer matches the : at the beginning of a Symbol.
    #
    # @param [String] token The token that the lexer matched.
    def on_symbeg(token)
      log "SYMBEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the -> as a lambda.
    #
    # @param [String] token The token that the lexer matched.
    def on_tlambda(token)
      log "TLAMBDA: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the { that represents the beginning of a
    # -> lambda.
    #
    # @param [String] token The token that the lexer matched.
    def on_tlambeg(token)
      log "TLAMBEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the beginning of a String.
    #
    # @param [String] token The token that the lexer matched.
    def on_tstring_beg(token)
      log "TSTRING_BEG: '#{token}'"
      current_line = LexedLine.new(super, lineno)
      tstring_beg_changed
      notify_tstring_beg_observers(current_line, lineno)
      super(token)
    end

    # Called when the lexer matches the content of any String.
    #
    # @param [String] token The token that the lexer matched.
    def on_tstring_content(token)
      log "TSTRING_CONTENT: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the end of a String.
    #
    # @param [String] token The token that the lexer matched.
    def on_tstring_end(token)
      log "TSTRING_END: '#{token}'"
      tstring_end_changed
      notify_tstring_end_observers(lineno)
      super(token)
    end

    # Called when the lexer matches '%W'.
    #
    # @param [String] token The token that the lexer matched.
    def on_words_beg(token)
      log "WORDS_BEG: '#{token}'"
      super(token)
    end

    # Called when the lexer matches the separators in a %w or %W (by default,
    # this is a single space).
    #
    # @param [String] token The token that the lexer matched.
    def on_words_sep(token)
      log "WORDS_SEP: '#{token}'"
      super(token)
    end

    # Called when the lexer matches __END__.
    #
    # @param [String] token The token that the lexer matched.
    def on___end__(token)
      log "__END__: '#{token}'"
      super(token)
    end

    # Called when the lexer matches CHAR.
    #
    # @param [String] token The token that the lexer matched.
    def on_CHAR(token)
      log "CHAR: '#{token}'"
      super(token)
    end

    # The current line of text being examined.
    #
    # @return [String] The current line of text.
    def current_line_of_text
      @file_text.split("\n").at(lineno - 1) || ''
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

    # Adds a newline to the end of the test if one doesn't exist.  Without doing
    # this, Ripper won't trigger a newline event for the last line of the file,
    # which is required for some rulers to do their thing.
    #
    # @param [String] file_text The text to check.
    # @return [String] The file text with a newline at the end.
    def ensure_trailing_newline(file_text)
      count_trailing_newlines(file_text) > 0 ? file_text : (file_text + "\n")
    end

    #---------------------------------------------------------------------------
    # Privates!
    #---------------------------------------------------------------------------
    private

    # Used internally as part of the hack to deal with Ripper's lack of dealing
    # with line-ending backslashes that break up statements.
    #
    # @param [String] file_text The file test to check.
    # @return [String] The altered file text.
    def sub_line_ending_backslashes(file_text)
      backslash_replacement = '# TAILOR REMOVED BACKSLASH'
      file_text.gsub!(/\\\s*\n?$/, backslash_replacement)

      file_text
    end

    def log(*args)
      l = begin; lineno; rescue; '<EOF>'; end
      c = begin; column; rescue; '<EOF>'; end
      subclass_name = self.class.to_s.sub(/^Tailor::/, '')
      args.first.insert(0, "<#{subclass_name}> #{l}[#{c}]: ")
      Tailor::Logger.log(*args)
    end
  end
end
