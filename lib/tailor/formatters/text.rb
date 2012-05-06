require 'pathname'
require 'term/ansicolor'
require 'text-table'
require_relative '../formatter'


class Tailor
  module Formatters
    class Text < Tailor::Formatter
      include Term::ANSIColor

      PROBLEM_LEVEL_COLORS = {
        error: 'red',
        warn: 'yellow'
      }

      # @return [String] A line of "#-----", with length determined by +length+.
      def line(length=79)
        "##{'-' * length}\n"
      end

      # @return [String] The portion of the header that displays the file info.
      def file_header(file)
        file = Pathname(file)
        message = "# "
        message << underscore { "File:\n" }
        message << "#   #{file.relative_path_from(@pwd)}\n"
        message << "#\n"

        message
      end

      # @return [String] The portion of the header that displays the file_set
      #   label info.
      def file_set_header(file_set)
        message = "# "
        message << underscore { "File Set:\n" }
        message << "#   #{file_set}\n"
        message << "#\n"

        message
      end

      # @return [String] The portion of the report that displays all of the
      #   problems for the file.
      def problems_header(problem_list)
        message = "# "
        message << underscore { "Problems:\n" }

        problem_list.each_with_index do |problem, i|
          color = PROBLEM_LEVEL_COLORS[problem[:level]] || 'white'

          position = position(problem[:line], problem[:column])
          message << "#  " + bold { "#{(i + 1)}." } + "\n"
          message << "#    * position:  "
          message << bold { instance_eval("#{color} position") } + "\n"
          message << "#    * property:  "
          message << instance_eval("#{color} problem[:type].to_s") + "\n"
          message << "#    * message:   "
          message << instance_eval("#{color} problem[:message].to_s") + "\n"
        end

        message
      end

      # @param [Fixnum] line
      # @param [Fixnum] column
      # @return [String] The position the problem was found at.
      def position(line, column)
        line == '<EOF>' ? '<EOF>' : "#{line}:#{column}"
      end

      # Prints the report on the file that just got checked.
      #
      # @param [Hash] problems Value should be the file name; keys should be
      #   problems with the file.
      def file_report(problems, file_set_label)
        return if problems.values.first.empty?

        file = problems.keys.first
        problem_list = problems.values.first
        message = line
        message << file_header(file)
        message << file_set_header(file_set_label)
        message << problems_header(problem_list)

        message << <<-MSG
#
#-------------------------------------------------------------------------------
        MSG

        puts message
      end

      # Prints the report on all of the files that just got checked.
      #
      # @param [Hash] problems Values are filenames; keys are problems for each
      #   of those files.
      def summary_report(problems)
        if problems.empty?
          puts "Your files are in style."
        else
          summary_table = ::Text::Table.new
          summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
          summary_table.rows << [{ value: "File", align: :center },
            { value: "Total Problems", align: :center }]
          summary_table.rows << :separator

          problems.each do |file, problem_list|
            file = Pathname(file)
            summary_table.rows << [
              file.relative_path_from(@pwd), problem_list.size
            ]
          end

          summary_table.rows << :separator

          problem_levels(problems).inject(summary_table.rows) do |result, level|
            result << [level.capitalize,
              problems_at_level(problems, level).size]
          end

          summary_table.rows << :separator
          summary_table.rows << ['TOTAL', problems.values.flatten.size]

          puts summary_table
        end
      end
    end
  end
end
