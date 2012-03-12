require_relative 'version'
require_relative '../tailor'
require 'text-table'

class Tailor

  # Just some methods to get stuff out of the CLI file.
  module CLIHelpers
    def config
      table = Text::Table.new(horizontal_padding: 4)
      table.head = [{ value: 'Configuration', colspan: 2, align: :center }]

      i = 0

      Tailor.config.each do |first_level,first_value|
        table.rows << [{ value: first_level.to_s.capitalize.gsub("_", " "),
          colspan: 2, align: :left }]
        table.rows << :separator

        if first_value.is_a? Hash
          first_value.each do |second_level,second_value|
            table.rows << [second_level, second_value]
          end
        else
          table.rows << [first_level, first_value]
        end

        i += 1
        table.rows << :separator unless Tailor.config.size == i
      end

      table
    end

    module_function :banner
    module_function :version
    module_function :about
    module_function :usage
    module_function :ruler
    module_function :config
  end
end
