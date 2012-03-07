Given /^(.+) exists$/ do |file_name|
  file_contents = get_file_contents(file_name)
  file_contents.should_not be_nil

  write_file(file_name, file_contents)
end

Given /^(.+) exists with a newline at the end$/ do |file_name|
  file_contents = get_file_contents(file_name)
  file_contents.should_not be_nil
  file_contents << "\n" unless file_contents[-1] == "\n"

  write_file(file_name, file_contents)
end

Given /^my configuration file "([^"]*)" looks like:$/ do |file_name, string|
  write_file(file_name, string)
end
