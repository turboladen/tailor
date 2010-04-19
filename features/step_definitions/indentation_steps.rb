$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'ruby_style_checker/indentation_checker'
require 'ruby_style_checker/file_line'

include RubyStyleChecker
include RubyStyleChecker::IndentationChecker

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

# Prep for the testing
Before do
  @ruby_style_checker = "#{File.dirname(__FILE__)}/../../bin/ruby_style_checker"
end

#-----------------------------------------------------------------------------
# "Given" statements
#-----------------------------------------------------------------------------
Given /^I have a project directory "([^\"]*)"$/ do |project_dir|
  project_dir = "support/#{project_dir}"
  File.exists?(project_dir).should be_true
  File.directory?(project_dir).should be_true
  @project_dir = project_dir
end

Given /^I have "([^\"]*)" file in my project$/ do |file_count|
  @file_list = Dir.glob("#{@project_dir}/*")
  @file_list.length.should == file_count.to_i
end

Given /^that file contains lines with hard tabs$/ do
  @ruby_source = File.open(@file_list[0], 'r')
  contains_hard_tabs = false
  @ruby_source.each_line do |line|
    source_line = RubyStyleChecker::FileLine.new line
    if source_line.hard_tabbed?
      contains_hard_tabs = true
      break
    end
  end
  contains_hard_tabs.should be_true
end

Given /^that file does not contain any "([^\"]*)" statements$/ do |keyword|
  @ruby_source = File.open(@file_list[0], 'r')

  count = count_keywords(@ruby_source, keyword)
  count.should == 0
end

Given /^the file contains only "([^\"]*)" "([^\"]*)" statement$/ do |count_in_spec, keyword|
  count_in_file = count_keywords(@ruby_source, keyword)
  count_in_file.should == count_in_spec.to_i
end

Given /^that file is indented properly$/ do
  @file_list.each do |file|
    RubyStyleChecker::IndentationChecker.validate_indentation file
  end
end

#-----------------------------------------------------------------------------
# "When" statements
#-----------------------------------------------------------------------------
When "I run the checker on the project" do
  #pending
  #result = exec ""
end

#-----------------------------------------------------------------------------
# "Then" statements
#-----------------------------------------------------------------------------
Then /^the checker should tell me each line that has a hard tab$/ do
  result = `#{@ruby_style_checker} #{@project_dir}`
  result.should include("Line is hard-tabbed")
end

Then "the checker should tell me my indentation is OK" do
  pending
end
  
