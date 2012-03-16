require 'ripper'
require_relative '../logger'

class Tailor
  class Ruler < Ripper::Lexer
    class IndentationRuler
      attr_reader :op_statement_nesting
      attr_reader :paren_nesting
      attr_reader :brace_nesting
      attr_reader :bracket_nesting
      attr_reader :tstring_nesting
      attr_reader :actual_indentation

      def initialize(indentation_config)
        @config = indentation_config

        @proper_indentation = {}
        log "Setting @proper_indentation[:this_line] to 0."
        @proper_indentation[:this_line] = 0
        @proper_indentation[:next_line] = 0
        @actual_indentation = 0
        @started = false

        @brace_nesting = []
        @bracket_nesting = []
        @paren_nesting = []
        @op_statement_nesting = []
        @tstring_nesting = []
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
        if started?
          @proper_indentation[:this_line] -= @config[:spaces]

          if @proper_indentation[:this_line] < 0
            @proper_indentation[:this_line] = 0
          end

          log "@proper_indentation[:this_line] = #{@proper_indentation[:this_line]}"
        else
          log "#decrease_this_line called, but checking is stopped."
        end
      end

      # Increases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def increase_next_line
        if started?
          @proper_indentation[:next_line] += @config[:spaces]
          log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
        else
          log "#increase_this_line called, but checking is stopped."
        end
      end

      # Decreases the indentation expectation for the next line by
      # +@config[:spaces]+.
      def decrease_next_line
        if started?
          @proper_indentation[:next_line] -= @config[:spaces]
          log "@proper_indentation[:next_line] = #{@proper_indentation[:next_line]}"
        else
          log "#decrease_next_line called, but checking is stopped."
        end
      end

      # Should be called just before moving to the next line.  This sets the
      # expectation set in +@proper_indentation[:next_line]+ to
      # +@proper_indentation[:this_line]+.
      def transition_lines
        if started?
          log "Setting @proper_indentation[:this_line] = that of :next_line"
          @proper_indentation[:this_line] = @proper_indentation[:next_line]
          log "transitioning @proper_indentation[:this_line] to #{@proper_indentation[:this_line]}"
        else
          log "skipping #transition_lines; checking is stopped." and return if started?
        end
      end

      # Starts the process of increasing/decreasing line indentation
      # expectations.
      def start
        log "Starting indentation ruling.  Next check should be at #{should_be_at}"
        @started = true
      end

      # Tells if the indentation checking process is on.
      #
      # @return [Boolean] +true+ if it's started; +false+ if not.
      def started?
        @started
      end

      # Stops the process of increasing/decreasing line indentation
      # expectations.
      def stop
        if started?
          log "Stopping indentation ruling.  Should be: #{should_be_at}; actual: #{actual_indentation}"
        end

        @started = false
      end

      # Updates +@actual_indentation+ based on the given lexed_line_output.
      #
      # @param [Array] lexed_line_output The lexed output for the current line.
      def update_actual_indentation(lexed_line_output)
        if end_of_multiline_string?(lexed_line_output)
          log "Found end of multiline string."
          return
        end

        first_non_space_element = lexed_line_output.find { |e| e[1] != :on_sp }
        @actual_indentation = first_non_space_element.first.last
        log "actual indentation: #{@actual_indentation}"
      end

      # Determines if the current lexed line is just the end of a tstring.
      #
      # @param [Array] lexed_line_output The lexed output for the current line.
      # @return [Boolean] +true+ if the line contains a +:on_tstring_end+ and
      #   not a +:on_tstring_beg+.
      def end_of_multiline_string?(lexed_line_output)
        lexed_line_output.any? { |e| e[1] == :on_tstring_end } &&
          lexed_line_output.none? { |e| e[1] == :on_tstring_beg }
      end

      #---------------------------------------------------------------------------
      # Privates!
      #---------------------------------------------------------------------------
      private

      def log(*args)
        args.first.insert(0, "<#{self.class}> ")
        Tailor::Logger.log(*args)
      end
    end
  end
end
