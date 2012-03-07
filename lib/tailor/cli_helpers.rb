require_relative 'version'
require_relative '../tailor'
require 'text-table'

class Tailor

  # Just some methods to get stuff out of the CLI file.
  module CLIHelpers

    # @return [String]
    def banner
      ruler + about + "\r\n" + usage + "\r\n"
    end

    # @return [String]
    def version
      ruler + about + "\r\n"
    end

    # @return [String]
    def ruler
      <<-RULER
  _________________________________________________________________________
  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  |
  |     |     |     |     |     |     |     |     |     |     |     |     |
  |           |           |           |           |           |           |
  |           1           2           3           4           5           |
  |                                                                       |
  -------------------------------------------------------------------------
      RULER
    end

    # @return [String]
    def about
      <<-ABOUT
  tailor (v#{Tailor::VERSION}).  \t\tA Ruby style checker.
\t\t\t\t\thttp://github.com/turboladen/tailor
      ABOUT
    end


    # @return [String]
    def usage
      <<-USEAGE
  Usage:
    $ #{File.basename($0)} [directory with .rb files]
      -OR-
    $ #{File.basename($0)} [single .rb file]"
      USEAGE
    end

    def config
      table = Text::Table.new(horizontal_padding: 4)
      table.head = [{ value: 'Configuration', colspan: 2, align: :center }]

      Tailor.config.each do |first_level,first_value|
        if first_value.is_a? Hash
          table.rows << [{ value: first_level.capitalize, colspan: 2, align: :left }]

          table.rows << :separator

          first_value.each do |second_level,second_value|
            table.rows << [second_level, second_value]
          end

        else
          table.rows << :separator
          table.rows << [first_level.to_s.capitalize.gsub("_", " "), first_value]
        end
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
