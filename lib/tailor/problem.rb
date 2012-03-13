class Tailor

  # A Hashed data structure that abstracts out data (especially the error
  # message) to build reports from.
  class Problem < Hash

    # @param [Symbol] type The problem type.
    # @param [Binding] binding The context that the problem was discovered in.
    def initialize(type, binding)
      @type = type
      @binding = binding
      set_values
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
        "Line is indented to #{@binding.eval('indentation')}, but should be at #{@binding.eval('@indentation_ruler.should_be_at')}"
      when :trailing_newlines
        "File has #{@binding.eval('trailing_newline_count')} trailing newlines, but should have #{@binding.eval('@config[:vertical_whitespace][:trailing_newlines]')}"
      end
    end
  end
end
