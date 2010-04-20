require 'ruby_style_checker/file_line'

def contains_camel_case? keyword
  @ruby_source = File.open(@file_list[0], 'r')

  contains_camel_case = false
  @ruby_source.each_line do |source_line|
    line = FileLine.new source_line

    if keyword.eql? "method"
      line.camel_case_method? ? (return true) : (return false)
    elsif keyword.eql? "class"
      line.camel_case_class? ? (return true) : (return false)
    end
  end
end

Given /^the file contains a "([^\"]*)" that has a camel\-cased name$/ do |keyword|
  contains_camel_case?(keyword).should be_true
end

Given /^the file contains a "([^\"]*)" that has a snake\-cased name$/ do |keyword|
    contains_camel_case?(keyword).should be_false
end

Then /^the checker should tell me I have a camel\-cased method name$/ do
  @result.should include("Method name uses camel case")
end

Then /^the checker shouldn't tell me the method name is camel\-case$/ do
  @result.should_not include("Method name uses camel case")
end

Then /^the checker shouldn't tell me the class name is camel\-case$/ do
  @result.should_not include("Class name uses camel case")
end

Then /^the checker should tell me the class name is not camel\-case$/ do
  @result.should include("Class name does NOT use camel case")
end