require 'ripper'

class Tailor
  class LineLexer < Ripper::Lexer
    INDENTATION_SPACE_COUNT = 2

    attr_reader :indentation_tracker
    attr_accessor :problems

    def method_missing(method_name, args)
      puts '---------------'
      Tailor.log method_name.to_s
      super
    end

    def initialize(source)
      @indentation_tracker = []
      Tailor.log "Setting @proper_indentation[:this_line] to 0."
      @proper_indentation = {}
      @proper_indentation[:this_line] = 0
      @proper_indentation[:next_line] = 0

      super source
    end

    def log *args
      args.first.insert(0, "#{lineno}: ")
      Tailor.log(*args)
    end

    # This is the first thing that exists on a new line--NOT the last!
    def on_nl(token)
      log "#on_nl"
      log "Setting @proper_indentation[:this_line] = that of :next_line"
      @proper_indentation[:this_line] = @proper_indentation[:next_line]
      log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
      log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      @current_line_lexed = current_line(super)
      log "@current_line_lexed = #{@current_line_lexed}"
      check_indentation unless actual_indentation.zero?
    end

    def current_line(me)
      log "#current_line.  Line: #{self.lineno}"
      me.find_all { |token| token.first.first == lineno }
    end

    def on_ignored_nl(token)
      log "#on_ignored_nl.  Ignoring line #{lineno}."
      @current_line_lexed = current_line(super)
    end

    def on_kw(token)
      log "#on_kw"

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

      unless @proper_indentation_level == (actual_indentation / INDENTATION_SPACE_COUNT)
        log "  * indentation doesn't match on:"
        p @current_line_lexed
        #raise "hell"
      end
    end
  end
end
