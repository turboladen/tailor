$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'ruby_style_checker'

include RubyStyleChecker


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

Given /^the file contains only "([^\"]*)" "([^\"]*)" statement$/ do |count_in_spec, keyword|
  #count_in_file = count_keywords(@ruby_source, keyword)
  count_in_file = count_keywords(@file_list[0], keyword)
  count_in_file.should == count_in_spec.to_i
end

Given /^I have "([^\"]*)" file in my project$/ do |file_count|
  @file_list = Dir.glob("#{@project_dir}/*")
  @file_list.length.should == file_count.to_i
end
