$:.unshift(File.dirname(__FILE__) + '/../../lib')

require 'ruby_style_checker'

include RubyStyleChecker

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
