require 'ruby_style_checker/file_line'

Given /^the file contains a method that has a camel\-cased name$/ do
  ruby_source = File.open(@file_list[0], 'r')
  
  contains_camel_case = false
  ruby_source.each_line do |source_line|
    line = FileLine.new source_line
    contains_camel_case = line.camel_case? ? true : false
    break
  end
  contains_camel_case.should be_true
end

Then /^the checker should tell me I have a camel\-cased method name$/ do
  result = `#{@ruby_style_checker} #{@project_dir}`
  result.should include("Method name uses camel case")
end