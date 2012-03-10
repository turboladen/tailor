require 'erb'
require 'yaml'
require 'log_switch'
require 'text-table'
require 'fileutils'
require_relative 'tailor/runtime_error'
require_relative 'tailor/line_lexer'

class Tailor
  extend LogSwitch

  #self.log = true

  class << self
    # Main entry-point method.
    #
    # @param [String] path File or directory to check files in.
    def check_style(path)
      file_list(path).each do |file|
        check_file(file)
      end
    end

    # The list of the files in the project to check.
    #
    # @param [String] path Path to the file or directory to check.
    # @return [Array] The list of files to check.
    def file_list(path=nil)
      return @file_list if @file_list

      if File.directory? path
        FileUtils.cd path
      else
        return [path]
      end

      files_in_project = Dir.glob(File.join('*', '**', '*'))
      Dir.glob(File.join('*')).each { |file| files_in_project << file }

      list_with_absolute_paths = []

      files_in_project.each do |file|
        if File.file? file
          list_with_absolute_paths << File.expand_path(file)
        end
      end

      @file_list = list_with_absolute_paths.sort
    end

    # Adds problems found from Lexing to the {problems} list.
    #
    # @param [String] file The file to open, read, and check.
    def check_file file
      Tailor.log "<#{self.name}> Checking style of a single file: #{file}."
      lexer = Tailor::LineLexer.new(file)
      lexer.lex
      problems[file] = lexer.problems
    end

    # @todo This could delegate to Ruport (or something similar) for allowing
    #   output of different types.
    def print_report
      if problems.empty?
        puts "Your files are in style."
      else
        summary_table = Text::Table.new
        summary_table.head = [{ value: "Tailor Summary", colspan: 2 }]
        summary_table.rows << [{ value: "File", align: :center},
          { value: "Total Problems", align: :center }]
        summary_table.rows << :separator

        problems.each do |file, problem_list|
          unless problem_list.empty?
            table = Text::Table.new do |t|
              t.head = ['File', { value: file, colspan: 2, align: :center }]
              t.rows << %w(line type message)
              t.rows << :separator

              problem_list.each do |problem|
                t.rows << [problem[:line], problem[:type], problem[:message]]
              end

              t.rows << :separator
              t.rows << [{ value: 'TOTAL', align: :right, colspan: 2 }, problem_list.size]
            end

            puts table
            puts
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
      problems.size
    end

    # Checks to see if +path_to_check+ is a real file or directory.
    #
    # @param [String] path_to_check
    # @return [Boolean]
    def checkable? path_to_check
      File.file?(path_to_check) || File.directory?(path_to_check)
    end

    # Tries to load a config file from ~/.tailor, then fails back on default
    # settings.
    #
    # @return [Hash] The configuration read from the config file or the default
    #   config.
    def config
      return @config if @config
      user_config_file = File.expand_path(Dir.home + '/.tailorrc')

      @config = if File.exists? user_config_file
        YAML.load_file user_config_file
      else
        erb_file = File.expand_path(File.dirname(__FILE__) + '/../tailor_config.yaml.erb')
        default_config_file = ERB.new(File.read(erb_file)).result(binding)
        YAML.load default_config_file
      end
    end

    # Use a different config file.
    #
    # @param [String] new_config_file Path to the new config file.
    def config=(new_config_file)
      @config = YAML.load_file(new_config_file)
    end
  end
end
