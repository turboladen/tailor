$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'fileutils'
require 'ruby_style_checker/file_line'

module RubyStyleChecker
  VERSION = '0.0.1'

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
    
  def self.check project_base_dir
    # Get the list of files to process
    ruby_files_in_project = project_file_list(project_base_dir)
    
    # Process each file
    ruby_files_in_project.each do |file_name|
      check_file file_name
    end
  end

  # Gets a list of .rb files in the project.  This gets each file's absolute path
  #   in order to alleviate any possible confusion.
  #
  # @param [String] base_dir Directory to start recursing from to look for .rb files
  # @return [Array] Sorted list of absolute file paths in the project
  def self.project_file_list base_dir
    if File.directory? base_dir
      FileUtils.cd base_dir
    end
    
    # Get the .rb files
    ruby_files_in_project = Dir.glob(File.join('*', '**', '*.rb'))
    Dir.glob(File.join('*.rb')).each { |f| ruby_files_in_project << f }
    
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
  def self.check_file file_name
    source = File.open(file_name, 'r')
    
    line_number = 1
    source.each_line do |source_line|
      line = FileLine.new source_line
      
      if line.hard_tabbed?
        puts "Line is hard-tabbed:\n\t#{file_name}: #{line_number}"
      end

      if line.method? and line.camel_case_method?
        puts "Method name uses camel case:\n\t#{file_name}: #{line_number}"
      end

      if line.class? and !line.camel_case_class?
        puts "Class name does NOT use camel case:\n\t#{file_name}: #{line_number}"
      end

      line_number = line_number + 1
    end
  end
end