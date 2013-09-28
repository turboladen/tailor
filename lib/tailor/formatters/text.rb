require 'pathname'
require 'term/ansicolor'
require_relative '../formatter'


class Tailor
  module Formatters
    class Text < Tailor::Formatter
      include Term::ANSIColor

      PROBLEM_LEVEL_COLORS = {
        error: 'red',
        warn: 'yellow'
      }

      # @return [String] A line of "#----#-", with length determined by +length+.
      def line(length=78)
        "##{'-' * length}#\n"
      end

      # @return [String] The portion of the header that displays the file info.
      def file_header(file)
        file = Pathname(file)
        message = '# '
        message << underscore { "File:\n" }
        message << "#   #{file.relative_path_from(@pwd)}\n"
        message << "#\n"

        message
      end

      # @return [String] The portion of the header that displays the file_set
      #   label info.
      def file_set_header(file_set)
        message = '# '
        message << underscore { "File Set:\n" }
        message << "#   #{file_set}\n"
        message << "#\n"

        message
      end

      # @return [String] The portion of the report that displays all of the
      #   problems for the file.
      def problems_header(problem_list)
        message = '# '
        message << underscore { "Problems:\n" }

        problem_list.each_with_index do |problem, i|
          color = PROBLEM_LEVEL_COLORS[problem[:level]] || 'white'

          position = position(problem[:line], problem[:column])
          message << '#  ' + bold { "#{(i + 1)}." } + "\n"
          message << '#    * position:  '
          message << bold { instance_eval("#{color} position") } + "\n"
          message << '#    * property:  '
          message << instance_eval("#{color} problem[:type].to_s") + "\n"
          message << '#    * message:   '
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

        message << "#\n"
        message << line

        puts message
      end

      MAX_STRING_SIZE = 68

      # Prints the report on all of the files that just got checked.
      #
      # @param [Hash] problems Values are filenames; keys are problems for each
      #   of those files.
      def summary_report(problems)
        summary_table = summary_header
        i = 0

        problems.each do |file, problem_list|
          report_line = summary_file_line(file, problem_list)

          report_line = if i % 2 == 1
            on_intense_black { report_line }
          else
            bold { report_line }
          end

          summary_table << '# ' << report_line << reset << "|\n"
          i += 1
        end

        summary_table << line
        summary_table << summary_level_totals(problems)
        summary_table << '#   ' << bold{ summary_first_col('TOTAL', 67) }
        summary_table << '|'
        summary_table << bold { total_problems(problems).to_s.rjust(6) }
        summary_table << " |\n"
        summary_table << line

        puts summary_table
      end

      def summary_header
        summary_table = line
        summary_table << '# '
        summary_table << bold { 'Tailor Summary'.rjust(40)  }
        summary_table << "|\n".rjust(39)
        summary_table << line
        summary_table << '#   ' << summary_first_col('File', 67) + '| '
        summary_table << 'Probs'.rjust(1)
        summary_table << " |\n".rjust(2)
        summary_table << line

        summary_table
      end

      def summary_file_line(file, problem_list)
        file = Pathname(file)
        relative_path = file.relative_path_from(@pwd)
        problem_count = problem_list.size

        "#{summary_first_col(relative_path)} | " +
          problem_count.to_s.rjust(5) + ' '
      end

      def summary_first_col(path, string_size=MAX_STRING_SIZE)
        fp = path.to_s.ljust(string_size)
        offset = fp.size - string_size
        end_of_string = fp[offset..-1]
        end_of_string.sub!(/^.{3}/, '...') unless offset.zero?

        end_of_string
      end

      def summary_level_totals(problems)
        return '' if total_problems(problems).zero?

        output = problem_levels(problems).inject('') do |result, level|
          color = PROBLEM_LEVEL_COLORS[level] || 'white'

          result << '#   '
          result << instance_eval("#{color} { summary_first_col(level.capitalize, 67) }")
          result << '|'
          result << instance_eval("#{color} { problems_at_level(problems, level).size.to_s.rjust(6) }")
          result << " |\n"
        end

        output << line

        output
      end

      def total_problems(problems)
        problems.values.flatten.size
      end
    end
  end
end
