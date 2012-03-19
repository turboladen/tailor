require_relative 'logger'

class Tailor

  # A Hashed data structure that abstracts out data (especially the error
  # message) to build reports from.
  class Problem < Hash
    include LogSwitch::Mixin

    # @param [Symbol] type The problem type.
    # @param [Binding] binding The context that the problem was discovered in.
    def initialize(type, binding)
      @type = type
      @binding = binding
      set_values
      log "<#{self.class}> #{self[:line]}[#{self[:column]}]: ERROR[:#{self[:type]}] #{self[:message]}"
    end

    # Sets the standard values for the problem based on the type and binding.
    def set_values
      self[:type] = @type
      self[:line] = @binding.eval("lineno")
      self[:column] = @binding.eval("column")
      self[:message] = message(@type)
    end

    # Builds the message for the problem type, based on the info provided in
    # the +@binding+.
    #
    # @param [Symbol] type The type of problem.
    # @return [String] The error message.
    def message(type)
      case type
      when :indentation
        self[:column] = @binding.eval('@indentation_ruler.actual_indentation')
        "Line is indented to #{@binding.eval('@indentation_ruler.actual_indentation')}, but should be at #{@binding.eval('@indentation_ruler.should_be_at')}"
      when :trailing_newlines
        "File has #{@binding.eval('trailing_newline_count')} trailing newlines, but should have #{@binding.eval('@config[:vertical_spacing][:trailing_newlines]')}"
      when :hard_tab
        "Hard tab found."
      when :line_length
        "Line is #{@binding.eval('current_line_of_text.length')} chars long, but should be #{@binding.eval('@config[:horizontal_spacing][:line_length]')}"
      end
    end
  end
end
