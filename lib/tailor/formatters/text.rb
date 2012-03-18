require 'text-table'

class Tailor
  module Formatter
    class Text

      # Prints the report on the file that just got checked.
      #
      # @param [Hash] problems Value should be the file name; keys should be
      #   problems with the file.
      def print_file_report(problems)
        return if problems.values.first.empty?

        file = problems.keys.first
        problem_list = problems.values.first

        message = "#-------------------------------------------------------------------------------\n"
        if defined? Term::ANSIColor
          message << "# #{'File:'.underscore}\n"
        else
          message << "# File:\n"
        end
        message << "#   #{file}\n"
        message << "#\n"
        if defined? Term::ANSIColor
          message << "# #{'Problems:'.underscore}\n"
        else
          message << "# Problems:\n"
        end

        problem_list.each_with_index do |problem, i|
          position = if problem[:line] == '<EOF>'
            '<EOF>'
          else
            if defined? Term::ANSIColor
              "#{problem[:line].to_s.red.bold}:#{problem[:column].to_s.red.bold}"
            else
              "#{problem[:line]}:#{problem[:column]}"
            end
          end

          if defined? Term::ANSIColor
            message << %Q{#  #{(i + 1).to_s.bold}.
#    * position:  #{position}
#    * type:      #{problem[:type].to_s.red}
#    * message:   #{problem[:message].red}
}
          else
            message << %Q{#  #{(i + 1)}.
#    * position:  #{position}
#    * type:      #{problem[:type]}
#    * message:   #{problem[:message]}
}
          end
        end

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
      def print_summary_report(problems)
        if problems.empty?
          puts "Your files are in style."
        else
          summary_table = ::Text::Table.new
          summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
          summary_table.rows << [{ value: "File", align: :center },
            { value: "Total Problems", align: :center }]
          summary_table.rows << :separator

          problems.each do |file, problem_list|
            summary_table.rows << [file, problem_list.size]
          end

          puts summary_table
        end
      end
    end
  end
end
