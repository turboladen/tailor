require 'ripper'

module Tailor
  class LineLexer < Ripper::Lexer
    def on_nl(token)
      @current = super
      check_line_ending
    end
    
    def check_line_ending
      p @current[@current.length - 1].last
    end
  end
end
