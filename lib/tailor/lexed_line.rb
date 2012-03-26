require_relative 'logger'
require_relative 'lexer_constants'

class Tailor
  class LexedLine < Array
    include LexerConstants

    def initialize(lexed_file, lineno)
      @lineno = lineno
      super(current_line_lex(lexed_file, lineno))
    end

    # @param [Array] lexed_output The lexed output for the whole file.
    # @return [Array]
    def current_line_lex(lexed_output, lineno)
      lexed_output.find_all { |token| token.first.first == lineno }
    end

    # Looks at self and determines if it' s a line of just
    # space characters: spaces, newlines.
    #
    # @return [Boolean]
    def only_spaces?
      element = first_non_space_element
      log "first non-space element '#{element}'"
      element.nil? || element.empty?
    end

    # Checks to see if the current line ends with an operator (not counting the
    # newline that might come after it).
    #
    # @return [Boolean] true if the line ends with an operator; false if not.
    def line_ends_with_op?
      lexed_line = self.dup
      tokens_in_line = lexed_line.map { |e| e[1] }

      until tokens_in_line.last != (:on_ignored_nl || :on_nl)
        tokens_in_line.pop
        lexed_line.pop
      end

      return false if lexed_line.empty?

      if MULTILINE_OPERATORS.include?(lexed_line.last.last) &&
        tokens_in_line.last == :on_op
        true
      else
        false
      end
    end

    def does_line_end_with(event)
      if last_non_line_feed_event.first.empty?
        false
      else
        last_non_line_feed_event[1] == event
      end
    end

    def method_missing(meth)
      if meth.to_s =~ /^line_ends_with_(.+)\?$/
        event = "on_#{$1}".to_sym
        does_line_end_with event
      else
        super(meth)
      end
    end

    # Gets the first non-space element from a line of lexed output.
    #
    # @return [Array] The element; +nil+ if none is found.
    def first_non_space_element
      self.find do |e|
        e[1] != :on_sp && e[1] != :on_nl && e[1] != :on_ignored_nl
      end
    end

    # Checks to see if the current line is a keyword loop (for, while, until)
    # that uses the optional 'do' at the end of the statement.
    #
    # @return [Boolean]
    def loop_with_do?
      keyword_elements = self.find_all { |e| e[1] == :on_kw }
      keyword_tokens = keyword_elements.map { |e| e.last }
      loop_start = keyword_tokens.any? { |t| LOOP_KEYWORDS.include? t }
      with_do = keyword_tokens.any? { |t| t == 'do' }

      loop_start && with_do
    end

    # @return [Boolean] +true+ if the line contains an keyword and it is in
    #   +KEYWORDS_TO_INDENT.
    def contains_keyword_to_indent?
      self.any? do |e|
        e[1] == :on_kw && KEYWORDS_TO_INDENT.include?(e[2])
      end
    end

    # @return [Array] The lexed event that represents the last event in the
    #   line that's not a +\n+.
    def last_non_line_feed_event
      self.find_all { |e| e[1] != :on_nl && e[1] != :on_ignored_nl }.last || [[]]
    end

    # @return [Fixnum] The length of the line minus the +\n+.
    def line_length
      event = last_non_line_feed_event
      return 0 if event.first.empty?

      event.first.last + event.last.size
    end
    
    # @param [Fixnum] column Number of the column to get the event for.
    # @return [Array] The event at the given column.
    def event_at column
      self.find { |e| e.first.last == column }
    end
    
    # Useful for inspecting events relevant to this one.
    #
    # @param [Fixnum] column Number of the column of which event to get the
    #   index for.
    # @return [Fixnum] The index within +self+ that the event is at.
    def event_index column
      column_event = self.event_at column
      self.index(column_event)
    end
    
    # @return [String] The string reassembled from self's tokens.
    def to_s
      self.inject('') { |new_string, e| new_string << e.last }
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
