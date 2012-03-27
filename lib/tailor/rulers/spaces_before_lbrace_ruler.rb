require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesBeforeLBraceRuler < Tailor::Ruler
      
      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] The number of spaces before the lbrace.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil? ||
          previous_event[1] == :on_embexpr_beg ||
          previous_event[1] == :on_lparen
          nil
        elsif previous_event[1] != :on_sp
          0
        else
          previous_event.last.size
        end
      end

      def lbrace_update(lexed_line, lineno, column)
        count = count_spaces(lexed_line, column)
        
        if count.nil?
          log "lbrace must be at the beginning of the line."
          return
        else
          log "Found #{count} space(s) before lbrace."
        end
        
        if count != @config
          @problems << Problem.new(:spaces_before_lbrace, lineno, column,
            { actual_spaces: count, should_have: @config })
        end
      end
    end
  end
end
