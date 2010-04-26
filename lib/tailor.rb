$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fileutils'
require 'pathname'
require 'tailor/file_line'

module Tailor
  VERSION = '0.0.2'

  RUBY_KEYWORDS_WITH_END = [
    'begin',
    'case',
    'class',
    'def',
    'do',
    'if',
    'unless',
    'until',
    'while'
    ]

  # Check all files in a directory for style problems.
  #
  # @param [String] project_base_dir Path to a directory to recurse into and
  #   look for problems in.
  # @return [Hash] Returns a hash that contains file_name => problem_count.
  def self.check project_base_dir
    # Get the list of files to process
    ruby_files_in_project = project_file_list(project_base_dir)

    files_and_problems = Hash.new

    # Process each file
    ruby_files_in_project.each do |file_name|
      problems = find_problems file_name
      files_and_problems[file_name] = problems
    end

    files_and_problems
  end

  # Gets a list of .rb files in the project.  This gets each file's absolute
  #   path in order to alleviate any possible confusion.
  #
  # @param [String] base_dir Directory to start recursing from to look for .rb
  #   files
  # @return [Array] Sorted list of absolute file paths in the project
  def self.project_file_list base_dir
    if File.directory? base_dir
      FileUtils.cd base_dir
    end

    # Get the .rb files
    ruby_files_in_project = Dir.glob(File.join('*', '**', '*.rb'))
    Dir.glob(File.join('*.rb')).each { |file| ruby_files_in_project << file }

    # Expand paths to all files in the list
    list_with_absolute_paths = Array.new
    ruby_files_in_project.each do |file|
      list_with_absolute_paths << File.expand_path(file)
    end

    list_with_absolute_paths.sort
  end

  # Checks a sing file for all defined styling parameters.
  #
  # @param [String] file_name Path to a file to check styling on.
  # @return [Number] Returns the number of errors on the file.
  def self.find_problems file_name
    source = File.open(file_name, 'r')
    file_path = Pathname.new(file_name)

    puts
    puts "#-------------------------------------------------------------------"
    puts "# Looking for bad style in:"
    puts "# \t'#{file_path}'"
    puts "#-------------------------------------------------------------------"

    @problem_count = 0
    line_number = 1
    source.each_line do |source_line|
      line = FileLine.new(source_line, file_path, line_number)

      # Check for indenting by spaces only
      if line.hard_tabbed?
        log_problem file_path, line_number
      end

      # Check for camel-cased methods
      if line.method_line? and line.camel_case_method?
        log_problem file_path, line_number
      end

      # Check for non-camel-cased classes
      if line.class_line? and line.snake_case_class?
        log_problem file_path, line_number
      end

      # Check for trailing whitespace
      if line.trailing_whitespace?
        log_problem file_path, line_number
      end

      # Check for long lines
      if line.too_long?
        log_problem file_path, line_number
      end

      # Check for spacing after commas
      if line.more_than_one_space_after_comma?
        log_problem file_path, line_number
      end

      # Check for spacing after commas
      if line.no_space_after_comma?
        log_problem file_path, line_number
      end

      # Check for spacing after commas
      if line.space_before_comma?
        log_problem file_path, line_number
      end

      line_number += 1
    end

    @problem_count
  end

  ##
  # Prints to screen where the problem was found and adds 1 to the total
  #   number of problems.
  # 
  # @param [Pathname] file_path Path of the file in which the problem
  #   occurred.
  # @param [Number] line_number Line number of the file in which the problem
  #   occurred.
  def self.log_problem file_path, line_number
    puts "\t#{file_path.relative_path_from(Pathname.pwd)}: #{line_number}"
    @problem_count += 1
  end

  # Prints a summary report that shows which files had how many problems.
  #
  # @param [Hash] files_and_problems Returns a hash that contains
  #   file_name => problem_count.
  def self.print_report files_and_problems
    puts
    puts "The following files are out of style:"

    files_and_problems.each_pair do |file, problem_count|
      file_path = Pathname.new(file)
      unless problem_count == 0
        puts "\t#{problem_count} problems in: #{file_path.relative_path_from(Pathname.pwd)}"
      end
    end
  end
end