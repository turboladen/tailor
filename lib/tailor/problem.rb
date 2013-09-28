require_relative 'logger'
require_relative 'runtime_error'

class Tailor

  # A Hashed data structure that simply defines the data needed to report a
  # problem
  class Problem < Hash
    include LogSwitch::Mixin

    # @param [Symbol] type The problem type.
    # @param [Fixnum] line The line of the file the problem was found on.
    # @param [Fixnum] column The column of the file line the problem was found on.
    # @param [String] message The message to tell the user about the problem.
    # @param [Fixnum] level The severity of the problem.
    def initialize(type, line, column, message, level)
      @type = type
      @line = line
      @column = column
      @message = message
      @level = level
      set_values
      subclass_name = self.class.to_s.sub(/^Tailor::/, '')
      msg = "<#{subclass_name}> #{self[:line]}[#{self[:column]}]: "
      msg << "#{@level.upcase}[:#{self[:type]}] #{self[:message]}"
      log msg
    end

    # Sets the standard values for the problem based on the type and binding.
    def set_values
      self[:type] = @type
      self[:line] = @line
      self[:column] = @column
      self[:message] = @message
      self[:level] = @level
    end
  end
end
