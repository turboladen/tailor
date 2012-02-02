require 'ripper'

class Tailor
  class LineLexer < Ripper::Lexer
    INDENTATION_SPACE_COUNT = 2
    KEYWORDS_TO_INDENT = [
      :class, :module, :def, :if, :elsif, :else, :do, :when, :begin, :rescue,
      :ensure, :case, :while
    ]
    CONTINUATION_KEYWORDS = [
      :elsif, :else, :when, :rescue, :ensure
    ]

    attr_reader :indentation_tracker, :keywords
    attr_accessor :problems


    # @param [String] source The source to analyze.
    def initialize(source)
      @indentation_tracker = []
      Tailor.log "Setting @proper_indentation[:this_line] to 0."
      @proper_indentation = {}
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0
      @keywords = []

      @problems = []

      super source
    end

    def log *args
      args.first.insert(0, "#{lineno}: ")
      Tailor.log(*args)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log "#on_nl"

      # check indentation
      c = current_lex(super)
      indentation = current_line_indent(c)
      if indentation != @proper_indentation[:this_line]
        message = "ERRRRORRRROROROROR! column (#{indentation}) != proper indent (#{@proper_indentation[:this_line]})"
        log message
        @problems << { type: :indentation, line: lineno, message: message }
      end

      # prep for next line
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"
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

    def on_ignored_nl(token)
      log "#on_ignored_nl.  Ignoring line #{lineno}."
      #@current_line_lexed = current_lex(super)
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
    end

    def on_kw(token)
      log "#on_kw. token: #{token}.  token class: #{token.class}"

      @keywords << { keyword: token, line: lineno, column: column }

      if KEYWORDS_TO_INDENT.include?(token.to_sym)
        log "indent keyword found: #{token}"

        #if token.to_sym == (:elsif || :else || :when)
        if CONTINUATION_KEYWORDS.include? token.to_sym
          @proper_indentation[:this_line] -= INDENTATION_SPACE_COUNT
        else
          @proper_indentation[:next_line] += INDENTATION_SPACE_COUNT
        end

        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

      if token == "end"
        log "outdent keyword found: end"
        @proper_indentation[:this_line] -= INDENTATION_SPACE_COUNT
        @proper_indentation[:next_line] -= INDENTATION_SPACE_COUNT
        log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

=begin
      case token
      when "class"
        log "#on_kw class.  @proper_indentation[:next_line] += 1"
        @proper_indentation[:next_line] += 1
        @indentation_tracker << { type: :class, inner_level: @proper_indentation[:next_line] }
      when "def"
        log "#on_kw def.  @proper_indentation[:next_line] += 1"
        @proper_indentation[:next_line] += 1
        @indentation_tracker << { type: :method, inner_level: @proper_indentation[:next_line] }
      when "end"
        log "#on_kw 'end'.  @proper_indentation[:next_line] -= 1"
        @proper_indentation[:next_line] -= 1
      else
        log "no rule for keyword '#{token}'..."
      end
=end

      log "@proper_indentation[:this_line]: #{@proper_indentation[:this_line]}"
      log "@proper_indentation[:next_line]: #{@proper_indentation[:next_line]}"

      super(token)
    end

    def actual_indentation
      log "#actual_indentation"
      log "token type = #{token_type}"

      if token_type == :on_sp
        log "token size = #{token_size}"
        @current_line_lexed.first.last.size
      else
        0
      end
    end

    def token_type
      @current_line_lexed.first[1]
    end

    def token_size
      @current_line_lexed.first.last.size
    end

    def check_indentation
      log "Checking indentation of line #{lineno}."
      log "  * correct column level: #{@proper_indentation[:this_line]}"
      log "  * column: #{column}"
      log "  * actual column level: #{actual_indentation}"

      #unless @proper_indentation_level == (actual_indentation / INDENTATION_SPACE_COUNT)
      #  log "  * indentation doesn't match on:"
      #  p @current_line_lexed
      #  #raise "hell"
      #end
    end
  end
end
