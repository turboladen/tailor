$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'tailor'

include Tailor

module CommonHelpers
  def in_tmp_folder(&block)
    FileUtils.chdir(@tmp_root, &block)
  end

  def in_project_folder(&block)
    project_folder = @active_project_folder || @tmp_root
    FileUtils.chdir(project_folder, &block)
  end

  def in_home_folder(&block)
    FileUtils.chdir(@home_path, &block)
  end

  def force_local_lib_override(project_name = @project_name)
    rakefile = File.read(File.join(project_name, 'Rakefile'))
    File.open(File.join(project_name, 'Rakefile'), "w+") do |f|
      f << "$:.unshift('#{@lib_path}')\n"
      f << rakefile
    end
  end

  def setup_active_project_folder project_name
    @active_project_folder = File.join(@tmp_root, project_name)
    @project_name = project_name
  end
end

World(CommonHelpers)

# Counts keywords in the file provided.
#
# @param [String] file Path to the file to check
# @param [String] keyword Keyword to count
# @return [Number] Number of keywords counted
def count_keywords file, keyword
  ruby_source = File.open(file, 'r')

  count = 0
  ruby_source.each_line do |line|
    if line =~ /^#{keyword}/
      count =+ 1
    end
  end
  ruby_source.close
  count
end

def check_file
  ruby_source = File.open(@file_list[0], 'r')

  ruby_source.each_line do |line|
    yield(line)
  end
end

# Prep for the testing
Before do
  @tailor = "#{File.dirname(__FILE__)}/../../bin/tailor"
end

#-----------------------------------------------------------------------------
# "Given" statements
#-----------------------------------------------------------------------------
Given /^I have a project directory "([^\"]*)"$/ do |project_dir|
  project_dir = "#{@features_path}/support/#{project_dir}"
  File.exists?(project_dir).should be_true
  File.directory?(project_dir).should be_true
  @project_dir = project_dir
end

Given /^the file contains only "([^\"]*)" "([^\"]*)" statement$/ do
  |count_in_spec, keyword|
  #count_in_file = count_keywords(@ruby_source, keyword)
  count_in_file = count_keywords(@file_list[0], keyword)
  count_in_file.should == count_in_spec.to_i
end

Given /^I have 1 file in my project$/ do
  @file_list = Dir.glob("#{@project_dir}/*")
  @file_list.length.should == 1
end

Given /^that file does not contain any "([^\"]*)" statements$/ do |keyword|
  ruby_source = File.open(@file_list[0], 'r')

  count = count_keywords(ruby_source, keyword)
  count.should == 0
end

#-----------------------------------------------------------------------------
# "When" statements
#-----------------------------------------------------------------------------
When "I run the checker on the project" do
  @result = `#{@tailor} #{@project_dir}`
end
