require 'erb'
require 'yaml'
require 'fileutils'
require_relative 'runtime_error'
require_relative 'logger'
require_relative 'line_lexer'
require_relative 'configuration'
require_relative '../ext/string_ext'


class Tailor
  class Critic
    include LogSwitch::Mixin

    def initialize(configuration)
      @configuration = configuration
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    # @return [Hash] The Problems for that file.
    def check_file file
      log "<#{self.class}> Checking style of a single file: #{file}."
      lexer = Tailor::LineLexer.new(file, @configuration)
      lexer.lex
      problems[file] = lexer.problems

      { file => problems[file] }
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      if problems.empty?
        puts "Your files are in style."
      else
        summary_table = Text::Table.new
        summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
        summary_table.rows << [{ value: "File", align: :center },
          { value: "Total Problems", align: :center }]
        summary_table.rows << :separator

        problems.each do |file, problem_list|
          unless problem_list.empty?
            print_file_problems(file, problem_list)
          end

          summary_table.rows << [file, problem_list.size]
        end

        puts summary_table
      end
    end

    # @return [Hash]
    def problems
      @problems ||= {}
    end

    # @return [Fixnum] The number of problems found so far.
    def problem_count
      problems.values.flatten.size
    end

    # Checks to see if +path_to_check+ is a real file or directory.
    #
    # @param [String] path_to_check
    # @return [Boolean]
    def checkable? path_to_check
      File.file?(path_to_check) || File.directory?(path_to_check)
    end
  end
end
