require_relative 'logger'
require_relative 'lexer/lexer_constants'
require_relative 'lexer/token'
require 'ripper'

class Tailor

  # This class provides methods for finding info about the current line.  It
  # works off the format that results from {Tailor::Lexer}.
  class LexedLine < Array
    include LexerConstants

    def initialize(lexed_file, lineno)
      @lineno = lineno
      super(current_line_lex(lexed_file, lineno))
    end

    # @param [Array] lexed_output The lexed output for the whole file.
    # @return [Array]
    def current_line_lex(lexed_output, lineno)
      lexed_output.find_all { |token| token.first.first == lineno }.uniq
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

    # @return [Boolean]
    def comment_line?
      first_non_space_element[1] == :on_comment
    end

    # Checks to see if the current line ends with an operator (not counting the
    # newline that might come after it).
    #
    # @return [Boolean] true if the line ends with an operator; false if not.
    def ends_with_op?
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

    # Checks to see if the line ends with a keyword, and that the keyword is
    # used as a modifier.
    #
    # @return [Boolean]
    def ends_with_modifier_kw?
      return false unless ends_with_kw?

      token = Tailor::Lexer::Token.new(last.last,
        { full_line_of_text: to_s })

      token.modifier_keyword?
    end

    # @return [Boolean]
    def does_line_end_with(event, exclude_newlines=true)
      if exclude_newlines
        if last_non_line_feed_event.first.empty?
          false
        else
          last_non_line_feed_event[1] == event
        end
      else
        self.last[1] == :on_ignored_nl || self.last[1] == :on_nl
      end
    end

    # Checks to see if the line contains only +event+ (where it may or may not
    # be preceded by spaces, and is proceeded by a newline).
    #
    # @param [Symbol] event The type of event to check for.
    # @return [Boolean]
    def is_line_only_a(event)
      last_event = last_non_line_feed_event
      return false if last_event[1] != event

      index = event_index(last_event.first.last)
      previous_event = self.at(index - 1)

      previous_event.first.last.zero? || previous_event.first.last.nil?
    end

    # Allows for calling a couple styles of methods:
    # * #ends_with_(.+)?  - Allows for checking if the line ends with (.+)
    # * #only_(.+)?  - Allows for checking if the line is only spaces and (.+)
    def method_missing(meth, *args, &blk)
      if meth.to_s =~ /^ends_with_(.+)\?$/
        event = "on_#{$1}".to_sym

        if event == :on_ignored_nl || event == :on_nl
          does_line_end_with(event, false)
        else
          does_line_end_with event
        end
      elsif meth.to_s =~ /^only_(.+)\?$/
        event = "on_#{$1}".to_sym
        is_line_only_a(event)
      else
        super(meth, *args, &blk)
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
    #   line that's not a line-feed.  Line-feed events are signified by
    #   +:on_nl+ and +on_ignored_nl+ events, and by +:on_sp+ events when they
    #   equal +"\\\n" (which occurs when a line is broken by a backslash).
    def last_non_line_feed_event
      events = self.find_all do |e|
        e[1] != :on_nl &&
          e[1] != :on_ignored_nl &&
          e.last != "\\\n"
      end

      events.last || [[]]
    end

    # @return [Fixnum] The length of the line minus the +\n+.
    def line_length
      event = last_non_line_feed_event
      return 0 if event.first.empty?

      event.first.last + event.last.size
    end

    # @param [Fixnum] column Number of the column to get the event for.
    # @return [Array] The event at the given column.
    def event_at(column)
      self.find { |e| e.first.last == column }
    end

    # Useful for inspecting events relevant to this one.
    #
    # @example
    #   i = lexed_line.event_index(11)
    #   previous_event = lexed_line.at(i - 1)
    # @param [Fixnum] column Number of the column of which event to get the
    #   index for.
    # @return [Fixnum] The index within +self+ that the event is at.
    def event_index(column)
      column_event = self.event_at column
      self.index(column_event)
    end

    # @return [String] The string reassembled from self's tokens.
    def to_s
      self.inject('') { |new_string, e| new_string << e.last }
    end

    # If a trailing comment exists in the line, remove it and the spaces that
    # come before it.  This is necessary, as +Ripper+ doesn't trigger an event
    # for the end of the line when the line ends with a comment.  Without this
    # observers that key off ending the line will never get triggered, and thus
    # style won't get checked for that line.
    #
    # @param [String] file_text The whole file's worth of text.  Required in
    #   order to be able to reconstruct the context in which the line exists.
    # @return [LexedLine] The current lexed line, but with the trailing comment
    #   removed.
    def remove_trailing_comment(file_text)
      file_lines = file_text.split("\n")
      lineno = self.last.first.first
      column = self.last.first.last
      log "Removing comment event at #{lineno}:#{column}."

      comment_index = event_index(column)
      self.delete_at(comment_index)
      self.insert(comment_index, [[lineno, column], :on_nl, "\n"])
      log "Inserted newline for comma; self is now #{self.inspect}"

      if self.at(comment_index - 1)[1] == :on_sp
        self.delete_at(comment_index - 1)
      end

      new_text = self.to_s
      log "New line as text: '#{new_text}'"

      file_lines.delete_at(lineno - 1)
      file_lines.insert(lineno - 1, new_text)
      file_lines = file_lines.join("\n")

      ripped_output = ::Ripper.lex(file_lines)
      LexedLine.new(ripped_output, lineno)
    end

    # Determines if the current lexed line is just the end of a tstring.
    #
    # @return [Boolean] +true+ if the line contains a +:on_tstring_end+ and
    #   not a +:on_tstring_beg+.
    def end_of_multi_line_string?
      self.any? { |e| e[1] == :on_tstring_end } &&
        self.none? { |e| e[1] == :on_tstring_beg }
    end

    # When Ripper lexes a Symbol, it generates one event for :on_symbeg, which
    # is the ':' token, and one for the name of the Symbol.  Since your Symbol
    # name can be anything, the second event could be something like "class", in
    # which case :on_kw will get called and probably result in unexpected
    # behavior.
    #
    # This assumes the keyword in question is the last event in the line.
    #
    # @return [Boolean]
    def keyword_is_symbol?
      current_index = self.index(self.last)
      previous_event = self.at(current_index - 1)

      return false if previous_event.nil?
      return false unless self.last[1] == :on_kw
      return false unless previous_event[1] == :on_symbeg

      true
    end

    #---------------------------------------------------------------------------
    # Privates!
    #---------------------------------------------------------------------------
    private

    def log(*args)
      l = begin; lineno; rescue; '<EOF>'; end
      c = begin; column; rescue; '<EOF>'; end
      subclass_name = self.class.to_s.sub(/^Tailor::/, '')
      args.first.insert(0, "<#{subclass_name}> #{l}[#{c}]: ")
      Tailor::Logger.log(*args)
    end
  end
end
