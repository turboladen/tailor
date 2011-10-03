require 'ripper'

module Tailor
  class LineLexer < Ripper::Lexer
    INDENTATION_SPACE_COUNT = 2

    attr_reader :indentation_tracker

    def method_missing(method_name, args)
      puts '---------------'
      puts method_name.to_s
      super
    end

    def initialize(source)
      @indentation_tracker = []
      @proper_indentation_level = 0

      super source
    end

    def on_nl(token)
      @current = current_line(super)
      check_indentation unless actual_indentation.nil?
    end

    def current_line(me)
      puts self.lineno
      me.find_all { |token| token.first.first == lineno }
    end

    def on_ignored_nl(token)
      @current = current_line(super)
    end

    def on_kw(token)
      case token
      when "class"
        @proper_indentation_level += 1
        @indentation_tracker << { type: :class, inner_level: @proper_indentation_level }
      when "def"
        @proper_indentation_level += 1
        @indentation_tracker << { type: :method, inner_level: @proper_indentation_level }
      when "end"
        @proper_indentation_level -= 1
      end
    end

    def actual_indentation
      if @current.first[1] == :on_sp
        @current.first.last.size
      else
        nil
      end
    end

    def check_indentation
      puts "correct indent level: #{@proper_indentation_level}"
      puts "column level: #{column}"
      puts "actual indent level: #{actual_indentation}"

      unless @proper_indentation_level == (actual_indentation / INDENTATION_SPACE_COUNT)
        puts "indentation doesn't match on:"
        p @current
        raise "hell"
      end
    end
  end
end
