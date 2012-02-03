require 'ripper'

class Tailor

  # https://github.com/svenfuchs/ripper2ruby/blob/303d7ac4dfc2d8dbbdacaa6970fc41ff56b31d82/notes/scanner_events
  class LineLexer < Ripper::Lexer
    KEYWORDS_TO_INDENT    = [
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
    CONTINUATION_KEYWORDS = [
      'elsif', 'else', 'when', 'rescue', 'ensure'
    ]

    attr_reader :indentation_tracker
    attr_accessor :problems

    # @param [String] file_name The name of the file to read and analyze.
    def initialize(file_name)
      @file_name = file_name
      file_text  = File.open(@file_name, 'r').read

      Tailor.log "Setting @proper_indentation[:this_line] to 0."
      @proper_indentation             = {}
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0
      @problems                       = []

      @config = Tailor.config[:indentation]
      super file_text
    end

    def log(*args)
      args.first.insert(0, "#{lineno}[#{column}]: ")
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
      log "#current_line.  Line: #{self.lineno}"

      lexed_output.find_all { |token| token.first.first == lineno }
    end

    # @return [Fixnum] Number of the first non-space (:on_sp) token.
    def current_line_indent(lexed_line_output)
      first_non_space_element = lexed_line_output.find { |e| e[1] != :on_sp }
      first_non_space_element.first.last
    end

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

    def on_ignored_nl(token)
      log "ignored_nl."

      # check indentation
      c           = current_lex(super)
      p c

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

    def on_kw(token)
      log "kw. token: #{token}"

      if KEYWORDS_TO_INDENT.include?(token)
        log "indent keyword found: #{token}"
        @indent_keyword_line = lineno

        if CONTINUATION_KEYWORDS.include? token
          @proper_indentation[:this_line] -= @config[:spaces]
        else
          @proper_indentation[:next_line] += @config[:spaces]
        end

        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

      if token == "end"
        log "outdent keyword found: end"

        unless single_line_indent_statement?
          @proper_indentation[:this_line] -= @config[:spaces]
        end

        @proper_indentation[:next_line] -= @config[:spaces]
        log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

      log "@proper_indentation[:this_line]: #{@proper_indentation[:this_line]}"
      log "@proper_indentation[:next_line]: #{@proper_indentation[:next_line]}"

      super(token)
    end

    def single_line_indent_statement?
      @indent_keyword_line == lineno
    end

    def on_lbracket(token)
      log "lbracket"
      @bracket_start_line             = lineno
      @proper_indentation[:next_line] += @config[:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def on_rbracket(token)
      log "rbracket"

      if multiline_brackets?
        @proper_indentation[:this_line] -= @config[:spaces]
      end

      @bracket_start_line = nil

      @proper_indentation[:next_line] -= @config[:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def on_lbrace(token)
      log "lbrace"
      @brace_start_line               = lineno
      @proper_indentation[:next_line] += @config[:spaces]
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      super(token)
    end

    def on_rbrace(token)
      log "rbrace"

      if multiline_braces?
        log "multiline braces!"
        @proper_indentation[:this_line] -= @config[:spaces]
      end

      @brace_start_line = nil

      # Ripper won't match a closing } in #{} so we have to track if we're
      # inside of one.  If we are, don't decrement then :next_line.
      unless @embexpr_beg
        @proper_indentation[:next_line] -= @config[:spaces]
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
      @bracket_start_line < lineno
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
