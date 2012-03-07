Given /^(.+) exists$/ do |file_name|
  file_contents = get_file_contents(file_name)
  file_contents.should_not be_nil

  write_file(file_name, file_contents)
end

Given /^(.+) exists with a newline at the end$/ do |file_name|
  file_contents = get_file_contents(file_name)
  file_contents.should_not be_nil
  file_contents << "\n"

  write_file(file_name, file_contents)
end
