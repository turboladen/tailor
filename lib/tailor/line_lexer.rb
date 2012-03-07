require 'ripper'
require_relative '../tailor'

class Tailor

  # https://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/scanner_events
  class LineLexer < Ripper::Lexer
    KEYWORDS_TO_INDENT     = [
      'begin',
      'case',
      'class',
      'def',
      'do',
      'else',
      'elsif',
      'ensure',
      'if',
      'module',
      'rescue',
      'unless',
      'when',
      'while'
    ]
    CONTINUATION_KEYWORDS  = [
      'elsif',
      'else',
      'ensure',
      'rescue',
      'when'
    ]
    KEYWORDS_AND_MODIFIERS = [
      'if',
      'unless',
      'until',
      'while'
    ]

    MODIFIERS = {
      'if'     => :if_mod,
      'rescue' => :rescue_mod,
      'unless' => :unless_mod,
      'until'  => :until_mod,
      'while'  => :while_mod
    }

    attr_reader :indentation_tracker
    attr_accessor :problems

    # @param [String] file_name The string to lex, or name of the file to read
    #   and analyze.
    def initialize(file)
      if File.exists? file
        @file_name = file
        @file_text = File.open(@file_name, 'r').read
      else
        @file_name = "<notafile>"
        @file_text = file
      end

      @problems = []
      @config = Tailor.config
      @file_text = ensure_trailing_newline(@file_text)
      p @file_text

      Tailor.log "<#{self.class}> Setting @proper_indentation[:this_line] to 0."
      @proper_indentation             = {}
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0

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
      count = count_trailing_newlines(text)
      puts "count: #{count}"

      if count != @config[:trailing_newlines]
        message = "File has #{count} trailing newlines, but should have #{@config[:trailing_newlines]}"

        @problems << {
          file_name: @file_name,
          type: :trailing_newlines,
          line: "<EOF>",
          message: message
        }
      end

      count > 0 ? text : (text + "\n")
    end

    def log(*args)
      args.first.insert(0, "<#{self.class}> #{lineno}[#{column}]: ")
      Tailor.log(*args)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log "nl"

      c = current_lex(super)

      # check indentation
      indentation = current_line_indent(c)

      if indentation != @proper_indentation[:this_line]
        message = "ERRRRORRRROROROROR! column (#{indentation}) != proper indent (#{@proper_indentation[:this_line]})"
        log message
        @problems << { file_name: @file_name, type: :indentation, line: lineno, message: message }
      end

      # prep for next line
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"

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
          message = "ERRRRORRRROROROROR! column (#{indentation}) != proper indent (#{@proper_indentation[:this_line]})"
          log message
          @problems << { file_name: @file_name, type: :indentation, line: lineno, message: message }
        end
      end

      # prep for next line
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"

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

    # Checks the current line to see if the given +token+ is being used as a
    # modifier.
    #
    # @return [Boolean] True if there's a modifier in the current line that
    #   is the same type as +token+.
    def modifier_keyword?(token)
      line_of_text = @file_text.split("\n").at(lineno - 1)
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
      log "indent keyword found: #{token}"
      @indent_keyword_line = lineno

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

    # Called when the lexer matches a [.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbracket(token)
      log "lbracket"
      @bracket_start_line             = lineno
      @proper_indentation[:next_line] += @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    # Called when the lexer matches a ].
    #
    # @param [String] token The token that the lexer matched.
    def on_rbracket(token)
      log "rbracket"

      if multiline_brackets?
        @proper_indentation[:this_line] -= @config[:indentation][:spaces]
      end

      @bracket_start_line = nil

      @proper_indentation[:next_line] -= @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    # Called when the lexer matches a {.  Note a #{ match calls
    # {on_embexpr_beg}.
    #
    # @param [String] token The token that the lexer matched.
    def on_lbrace(token)
      log "lbrace"
      @brace_start_line               = lineno
      @proper_indentation[:next_line] += @config[:indentation][:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
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

      @brace_start_line = nil

      # Ripper won't match a closing } in #{} so we have to track if we're
      # inside of one.  If we are, don't decrement then :next_line.
      unless @embexpr_beg
        @proper_indentation[:next_line] -= @config[:indentation][:spaces]
      end

      @embexpr_beg = false
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def multiline_braces?
      if @brace_start_line.nil?
        false
      else
        @brace_start_line < lineno
      end
    end

    def multiline_brackets?
      if @bracket_start_line.nil?
        false
      else
        @bracket_start_line < lineno
      end
    end

    def on_embexpr_beg(token)
      log "embexpr_beg"
      @embexpr_beg = true
      super(token)
    end

    def on_embexpr_end(token)
      log "embexpr_end: token: '#{token}'"
      super(token)
    end
  end
end
