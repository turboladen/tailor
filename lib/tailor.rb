require 'fileutils'
require 'pathname'
require_relative 'tailor/version'
require_relative 'tailor/file_line'
require_relative 'tailor/spacing'
require_relative 'tailor/line_lexer'

module Tailor

  # These operators should always have 1 space around them
  OPERATORS = {
    :arithmetic => ['+', '-', '*', '/', '%', '++', '--', '**'],
    :assignment => ['=', '+=', '-=', '*=', '/=', '%=', '*=', '**=', '|', '&=',
      '&&=', '>>=', '<<=', '||='],
    :comparison => ['==', '===', '!=', '>', '<', '>=', '<=', '<=>', '!', '~'],
    :gem_version => ['~>'],
    :logical => ['&&', '||', 'and', 'or'],
    :regex => ['^', '|', '!~', '=~'],
    :shift => ['<<', '>>'],
    :ternary => ['?', ':']
  }

  # These operators should never have spaces around them.
  NO_SPACE_AROUND_OPERATORS = {
    :range => ['..', '...'],
    :scope_resolution => ['::']
  }

  # Don't do anything about these ops; they're just here so we know not to do
  # anything with them.
  DO_NOTHING_OPS = {
    :elements => ['[]', '[]=']
  }

  # Check all files in a directory for style problems.
  #
  # @param [String] project_base_dir Path to a directory to recurse into and
  # look for problems in.
  # @return [Hash] Returns a hash that contains file_name => problem_count.
  def self.check project_base_dir
    # Get the list of files to process
    ruby_files_in_project = project_file_list(project_base_dir)

    files_and_problems = Hash.new

    # Process each file
    ruby_files_in_project.each do |file_name|
      problems = find_problems_in file_name
      files_and_problems[file_name] = problems
    end

    files_and_problems
  end


  # Check a single file for style problems.
  #
  # @param [String] file_name Path to a file to check style on.
  # @return [Hash] Returns a hash that contains file_name => problem_count.
  def self.check_file file_name
    files_and_problems = Hash.new

    problems = find_problems_in(file_name: File.expand_path(file_name))
    files_and_problems[file_name] = problems

    files_and_problems
  end

  # Gets a list of .rb files in the project.  This gets each file's absolute
  # path in order to alleviate any possible confusion.
  #
  # @param [String] base_dir Directory to start recursing from to look for .rb
  # files.
  # @return [Array] Sorted list of absolute file paths in the project.
  def self.project_file_list base_dir
    if File.directory? base_dir
      FileUtils.cd base_dir
    end

    # Get the .rb files
    ruby_files_in_project = Dir.glob(File.join('*', '**', '*.rb'))
    Dir.glob(File.join('*.rb')).each { |file| ruby_files_in_project << file }

    # Get the .erb files
    Dir.glob(File.join('*.erb')).each { |file| ruby_files_in_project << file }

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
  # @param [Hash] options
  # @option options [String] file_name
  # @option options [String] source_string
  # @return [Number] Returns the number of errors on the file.
  def self.find_problems_in options
    if options[:file_name]
      source = File.open(options[:file_name], 'r')
      file_path = Pathname.new(options[:file_name])
    elsif options[:source_string]
      source = options[:source_string]
      puts source
    else
      # Old way.  Keep for old compat; nuke after proving ripper.
      source = File.open(options, 'r')
      file_path = Pathname.new(options)
    end

    puts ""
    puts "#-------------------------------------------------------------------"
    puts "# Looking for bad style in:"
    puts "# \t'#{file_path}'"
    puts "#-------------------------------------------------------------------"

    @problem_count = 0
    parsed_file = Tailor::LineLexer.new(source).parse

    parsed_file.each do |token|
      line_number = token.first.first
      code = token.last
      puts code
      not_really_a_line = FileLine.new(code, file_path, line_number)
      not_really_a_line.spacing_problems
    end
=begin
    current_level = 0.0
    next_level = 0.0
    multi_line_next_level = 0.0
    multi_line = false

    source.each_line do |source_line|
      line = FileLine.new(source_line, file_path, line_number)

      puts "line num: #{line_number}"
if line.ends_with_comma?
  puts "COMMA"
end
if line.ends_with_backslash?
  puts "BACKSLASH"
end
if line.ends_with_operator?
  puts "OPERATOR"
end
if line.unclosed_parenthesis?
  puts "PARENTHESIS"
end

      multi_line_statement = line.multi_line_statement?

      # If we're not in a multi-line statement, but this is the beginning of
      # one...
      if multi_line == false and multi_line_statement
        multi_line = true
        multi_line_next_level = current_level + 1.0
        puts ":multi-line: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      # If we're already in a multi-line statement...
      elsif multi_line == true and multi_line_statement
        puts ":multi-line: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
        # Keep current_line and next_line the same
      elsif multi_line == true and !multi_line_statement and line.indent?
        #next_level -= 1.0
        puts ":multi-line: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      else
        multi_line = false
      end

      if line.outdent?
        current_level -= 1.0
        next_level = current_level + 1.0
        puts ":outdent: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      end

      if line.contains_end?
        current_level -= 1.0
        next_level = current_level
        puts ":end: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      end

      if multi_line == true and !multi_line_statement and line.indent?
      elsif line.indent?
        next_level = current_level + 1.0
        puts ":indent: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      end

      if !line.indent? and !line.outdent? and !line.contains_end?
        puts ":same: current = #{current_level}; next = #{next_level}" +
          "; multi_line_next = #{multi_line_next_level}"
      end

      #if line.indent? or line.outdent? or line.contains_end?
        if line.at_improper_level? current_level
          @problem_count += 1
        end
      #end

      # If this is the last line of the multi-line statement...
      if multi_line == true and multi_line_statement
        puts "Assigning current (#{current_level}) to multi_next (#{multi_line_next_level})"
        current_level = multi_line_next_level
      elsif multi_line == true and !multi_line_statement
        multi_line = false
        puts "Assigning current (#{current_level}) = next (#{next_level}) "
        current_level = next_level
      #elsif multi_line == false
      else
        puts "Assigning current (#{current_level}) = next (#{next_level}) "
        current_level = next_level
      end
      @problem_count += line.spacing_problems

      # Check for camel-cased methods
      @problem_count += 1 if line.method_line? and line.camel_case_method?

      # Check for non-camel-cased classes
      @problem_count += 1 if line.class_line? and line.snake_case_class?

      # Check for long lines
      @problem_count += 1 if line.too_long?

      # Check for spacing around operators
      OPERATORS.each_pair do |op_group, op_values|
        op_values.each do |op|
          @problem_count += 1 if line.no_space_before? op
          @problem_count += 1 if line.no_space_after? op
        end
      end

      line_number += 1
    end
=end

    @problem_count
  end

  # Prints a summary report that shows which files had how many problems.
  #
  # @param [Hash] files_and_problems Returns a hash that contains
  # file_name => problem_count.
  def self.print_report files_and_problems
    puts ""
    puts "The following files are out of style:"

    files_and_problems.each_pair do |file, problem_count|
      file_path = Pathname.new(file)

      unless problem_count == 0
        print "\t#{problem_count} problems in: "

        if files_and_problems.size > 1
          puts "#{file_path.relative_path_from(Pathname.pwd)}"
        else
          puts "#{file_path}"
        end
      end
    end
  end
end
