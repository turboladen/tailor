require_relative '../ruler'

class Tailor
  class HorizontalSpacingRuler < Tailor::Ruler
    def ignored_nl_update(current_lexed_line, lineno, column)
      log "<#{self.class}> Line length: #{current_lexed_line.line_length}"

      if @config[:line_length]
        if line_too_long?(current_lexed_line)
          options = {
            actual_length: current_lexed_line.line_length,
            should_be_at: @config[:line_length]
          }
          @problems << Problem.new(:line_length, lineno, column, options)
          log "ERROR: Line length.  #{@problems.last[:message]}"
        end
      end
    end

    def nl_update(current_lexed_line, lineno, column)
      ignored_nl_update(current_lexed_line, lineno, column)
    end

    def line_too_long?(current_lexed_line)
      current_lexed_line.line_length > @config[:line_length]
    end
  end
end
