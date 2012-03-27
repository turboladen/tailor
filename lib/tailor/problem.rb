require_relative 'logger'
require_relative 'runtime_error'

class Tailor

  # A Hashed data structure that abstracts out data (especially the error
  # message) to build reports from.
  class Problem < Hash
    include LogSwitch::Mixin

    # @param [Symbol] type The problem type.
    # @param [Binding] binding The context that the problem was discovered in.
    def initialize(type, line, column, options={})
      @type = type
      @line = line
      @column = column
      @options = options
      set_values
      msg = "<#{self.class}> #{self[:line]}[#{self[:column]}]: "
      msg << "ERROR[:#{self[:type]}] #{self[:message]}"
      log msg
    end

    # Sets the standard values for the problem based on the type and binding.
    def set_values
      self[:type] = @type
      self[:line] = @line
      self[:column] = @column
      self[:message] = message(@type)
    end

    # Builds the message for the problem type, based on the info provided in
    # the +@binding+.
    #
    # @param [Symbol] type The type of problem.
    # @return [String] The error message.
    def message(type)
      case type
      when :camel_case_method
        "Camel-case method name found."
      when :hard_tab
        "Hard tab found."
      when :indentation
        self[:column] = @options[:actual_indentation]
        msg = "Line is indented to #{@options[:actual_indentation]}, "
        msg << "but should be at #{@options[:should_be_at]}."
      when :line_length
        msg = "Line is #{@options[:actual_length]} chars long, "
        msg << "but should be #{@options[:should_be_at]}."
      when :screaming_snake_case_class_name
        "Screaming-snake-case class/module found."
      when :spaces_after_comma
        msg = "Line has #{@options[:actual_spaces]} spaces after a comma, "
        msg << "but should have #{@options[:should_have]}."
      when :spaces_before_comma
        msg = "Line has #{@options[:actual_spaces]} spaces before a comma, "
        msg << "but should have #{@options[:should_have]}."
      when :spaces_before_lbrace
        msg = "Line has #{@options[:actual_spaces]} spaces before a left brace,"
        msg << " but should have #{@options[:should_have]}."
      when :trailing_newlines
        msg = "File has #{@options[:actual_trailing_newlines]} trailing "
        msg << "newlines, but should have #{@options[:should_have]}."
      when :trailing_spaces
        "Line has #{@options[:actual_trailing_spaces]} trailing spaces."
      else
        raise Tailor::RuntimeError,
          "Problem type '#{type}' doesn't exist."
      end
    end
  end
end
