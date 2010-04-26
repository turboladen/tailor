$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'tailor/indentation_checker'
require 'tailor/file_line'

include Tailor
include Tailor::IndentationChecker

def check_file
  ruby_source = File.open(@file_list[0], 'r')

  ruby_source.each_line do |line|
    yield(line)
  end
end

def check_spacing method_name, line_type
  is_line_type = false
  bad_spacing = false
  line_number = 1

  file_path = Pathname.new(File.expand_path(@file_list[0]))

  check_file do |line|
    source_line = Tailor::FileLine.new(line, file_path, line_number)

    is_line_type = source_line.send("#{line_type}_line?")
    bad_spacing = source_line.send(method_name)

    break line if is_line_type == true and bad_spacing == true

    line_number += 1
  end

  is_line_type.should be_true
  bad_spacing.should be_true
end

#-----------------------------------------------------------------------------
# "Given" statements
#-----------------------------------------------------------------------------
Given /^that file contains lines with hard tabs$/ do
  contains_hard_tabs = false
  line_number = 1

  file_path = Pathname.new(File.expand_path(@file_list[0]))

  check_file do |line|
    source_line = Tailor::FileLine.new(line, file_path, line_number)
    if source_line.hard_tabbed?
      contains_hard_tabs = true
      break
    end
    line_number += 1
  end

  contains_hard_tabs.should be_true
end

Given /^that file does not contain any "([^\"]*)" statements$/ do |keyword|
  ruby_source = File.open(@file_list[0], 'r')

  count = count_keywords(ruby_source, keyword)
  count.should == 0
end

Given /^that file is indented properly$/ do
  pending
end

Given /^that file contains lines with trailing whitespace$/ do
  line_number = 1

  file_path = Pathname.new(File.expand_path(@file_list[0]))

  check_file do |line|
    source_line = Tailor::FileLine.new(line, file_path, line_number)

    @whitespace_count = source_line.trailing_whitespace_count

    @whitespace_count.should > 0

    line_number += 1
  end
end

Given /^that file contains lines longer than 80 characters$/ do
  line_number = 1

  file_path = Pathname.new(File.expand_path(@file_list[0]))

  check_file do |line|
    source_line = Tailor::FileLine.new(line, file_path, line_number)

    if source_line.too_long?
      too_long = true
      break
    else
      too_long = false
    end

    too_long.should be_true

    line_number += 1
  end
end

Given /^that file contains a "([^\"]*)" line without spaces after commas$/ do |line_type|
  check_spacing("no_space_after_comma?", line_type)
end

Given /^that file contains a "([^\"]*)" line with > 1 spaces after commas$/ do |line_type|
  check_spacing("more_than_one_space_after_comma?", line_type)
end

Given /^that file contains a "([^\"]*)" line with spaces before commas$/ do |line_type|
  check_spacing("space_before_comma?", line_type)
end

Given /^that file contains a "([^\"]*)" line with spaces after open parentheses$/ do |line_type|
  check_spacing("space_after_open_parenthesis?", line_type)
end

Given /^that file contains a "([^\"]*)" line with spaces after an open bracket$/ do |line_type|
  check_spacing("space_after_open_bracket?", line_type)
end

Given /^that file contains a "([^\"]*)" line with spaces after an open parenthesis$/ do |line_type|
  check_spacing("space_before_closed_parenthesis?", line_type)
end

#-----------------------------------------------------------------------------
# "When" statements
#-----------------------------------------------------------------------------
When "I run the checker on the project" do
  @result = `#{@tailor} #{@project_dir}`
end

#-----------------------------------------------------------------------------
# "Then" statements
#-----------------------------------------------------------------------------
Then /^the checker should tell me each line that has a hard tab$/ do
  @result.should include("Line contains hard tabs")
end

Then "the checker should tell me my indentation is OK" do
  pending
end

Then /^the checker should tell me each line has trailing whitespace$/ do
  @result.should include("Line contains #{@whitespace_count} trailing whitespace(s)")
end

Then /^the checker should tell me each line is too long$/ do
  message = "Line is greater than #{Tailor::FileLine::LINE_LENGTH_MAX} characters"
  @result.should include(message)
end

Then /^the checker should tell me each line has commas without spaces after them$/ do
  message = "Line has a comma with 0 spaces after it"
  @result.should include(message)
end

Then /^the checker should tell me each line has commas with spaces before them$/ do
  message = "Line has at least one space before a comma"
  @result.should include(message)
end

Then /^the checker should tell me each line has commas with > 1 spaces after them$/ do
  message = "Line has a comma with > 1 space after it"
  @result.should include(message)
end

Then /^the checker should tell me each line has open parentheses with spaces before them$/ do
  message = "Line has an open parenthesis with spaces after it"
  @result.should include(message)
end

Then /^the checker should tell me each line has open brackets with spaces before them$/ do
  message = "Line has an open bracket with spaces after it"
  @result.should include(message)
end

Then /^the checker should tell me each line has closed parentheses with spaces before them$/ do
  message = "Line has a closed parenthesis with spaces before it"
  @result.should include(message)
end

Then /^the checker should tell me each line has closed brackets with spaces before them$/ do
  message = "Line has a closed bracket with spaces before it"
  @result.should include(message)
end