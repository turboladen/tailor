require_relative '../ruler'

class Tailor
  class HorizontalSpacingRuler < Tailor::Ruler
    def ignored_nl_update(lexed_line, lineno, column)
      check_line_length(lexed_line, lineno, column)
      check_line_end_for_spaces(lexed_line, lineno, column)
    end

    def nl_update(lexed_line, lineno, column)
      ignored_nl_update(lexed_line, lineno, column)
    end

    def sp_update(token, lineno, column)
      check_hard_tab(token, lineno, column)
    end

    def check_hard_tab(token, lineno, column)
      unless @config[:allow_hard_tabs]
        if token =~ /\t/
          @problems << Problem.new(:hard_tab, lineno, column)
          log "ERROR: Hard tab.  #{@problems.last[:message]}"
        end
      end
    end

    def check_line_length(lexed_line, lineno, column)
      log "<#{self.class}> Line length: #{lexed_line.line_length}"

      if @config[:line_length]
        if lexed_line.line_length > @config[:line_length]
          options = {
            actual_length: lexed_line.line_length,
            should_be_at: @config[:line_length]
          }
          @problems << Problem.new(:line_length, lineno, column, options)
          log "ERROR: Line length.  #{@problems.last[:message]}"
        end
      end
    end

    def check_line_end_for_spaces(lexed_line, lineno, column)
      log "last event: #{lexed_line.last_non_line_feed_event}"
      
      unless @config[:allow_trailing_spaces]
        log lexed_line.line_ends_with_sp?
        
        if lexed_line.line_ends_with_sp?
          log "<#{self.class}> Last event: #{lexed_line.last_non_line_feed_event}"
          options = {
            actual_trailing_spaces: lexed_line.last_non_line_feed_event.last.size
          }
          @problems << Problem.new(:trailing_spaces, lineno, column, options)
        end
      end
    end
  end
end
