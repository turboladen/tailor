$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'ruby_style_checker/indentation_checker'
require 'ruby_style_checker/file_line'

include RubyStyleChecker
include RubyStyleChecker::IndentationChecker

#-----------------------------------------------------------------------------
# "Given" statements
#-----------------------------------------------------------------------------
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


Given /^that file is indented properly$/ do
  @file_list.each do |file|
    RubyStyleChecker::IndentationChecker.validate_indentation file
  end
end

#-----------------------------------------------------------------------------
# "When" statements
#-----------------------------------------------------------------------------
When "I run the checker on the project" do
  @result = `#{@ruby_style_checker} #{@project_dir}`
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
  
