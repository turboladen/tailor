require_relative '../ruler'

class Tailor
  module Rulers
    class SpacesBeforeRBracketRuler < Tailor::Ruler
      def initialize(config)
        super(config)
      end
      
      # @param [LexedLine] lexed_line
      # @param [Fixnum] column
      # @return [Fixnum] The number of spaces before the rbracket.
      def count_spaces(lexed_line, column)
        current_index = lexed_line.event_index(column)
        log "Current event index: #{current_index}"
        previous_event = lexed_line.at(current_index - 1)
        log "Previous event: #{previous_event}"

        if column.zero? || previous_event.nil? ||
          previous_event[1] == :on_lbracket
          return nil
        end
        
        return 0 if previous_event[1] != :on_sp
        return nil if current_index - 2 < 0
        
        second_previous_event = lexed_line.at(current_index - 2)
        return nil if second_previous_event[1] == :on_lbracket
        
        previous_event.last.size
      end
      
      # This has to keep track of '{'s and only follow through with the check
      # if the '{' was an lbrace because Ripper doesn't scan the '}' of an
      # embedded expression (embexpr_end) as such.
      #
      # @param [Tailor::LexedLine] lexed_line
      # @param [Fixnum] lineno
      # @param [Fixnum] column
      def rbracket_update(lexed_line, lineno, column)
        count = count_spaces(lexed_line, column)
        
        if count.nil?
          log "rbracket must be at the beginning of the line."
          return
        else
          log "Found #{count} space(s) before rbracket."
        end
        
        if count != @config
          @problems << Problem.new(:spaces_before_rbracket, lineno, column,
            { actual_spaces: count, should_have: @config })
        end
      end
    end
  end
end
