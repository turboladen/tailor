require_relative 'logger'
require_relative 'problem'

class Tailor
  class HorizontalSpacingRuler
    def initialize(config)
      @config = config
    end

    def on_ignored_nl(line_of_text, lineno, column)
      if @config[:line_length]
        if line_too_long?(line_of_text)
          options = {
            actual_length: line_of_text.length,
            should_be_at: @config[:line_length]
          }
          @problems << Problem.new(:line_length, lineno, column, options)
        end
      end
    end

    def line_too_long?(line_of_text)
      line_of_text.length > @config[:line_length]
    end
  end
end