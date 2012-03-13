require 'ripper'
require_relative '../logger'

class Tailor
  class Ruler < Ripper::Lexer
    class IndentationRuler
      attr_reader :op_statement_nesting
      attr_reader :paren_nesting
      attr_reader :brace_nesting
      attr_reader :bracket_nesting

      def initialize(indentation_config)
        @config = indentation_config
        @proper_indentation = {}
        log "Setting @proper_indentation[:this_line] to 0."
        @proper_indentation[:this_line] = 0
        @proper_indentation[:next_line] = 0
        @brace_nesting = []
        @bracket_nesting = []
        @paren_nesting = []
        @op_statement_nesting = []
      end

      # @return [Fixnum] The indent level the file should currently be at.
      def should_be_at
        @proper_indentation[:this_line]
      end

      def next_should_be_at
        @proper_indentation[:next_line]
      end

      # Decreases the indentation expectation for the current line by
      # +@config[:spaces]+.
      def decrease_this_line
        @proper_indentation[:this_line] -= @config[:spaces]

        if @proper_indentation[:this_line] < 0
          @proper_indentation[:this_line] = 0
        end

        log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
      end

      # Increases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def increase_next_line
        @proper_indentation[:next_line] += @config[:spaces]
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

      # Decreases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def decrease_next_line
        @proper_indentation[:next_line] -= @config[:spaces]
        log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
      end

      # Should be called just before moving to the next line.  This sets the
      # expectation set in +@proper_indentation[:next_line]+ to
      # +@proper_indentation[:this_line]+.
      def transition_lines
        log "Setting @proper_indentation[:this_line] = that of :next_line"
        @proper_indentation[:this_line] = @proper_indentation[:next_line]
        log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"
      end

      #---------------------------------------------------------------------------
      # Privates!
      #---------------------------------------------------------------------------
      private

      def log(*args)
        l = begin; lineno; rescue; "<EOF>"; end
        c = begin; column; rescue; "<EOF>"; end
        args.first.insert(0, "<#{self.class}> #{l}[#{c}]: ")
        Tailor::Logger.log(*args)
      end
    end
  end
end
