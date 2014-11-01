Given /^(.+) exists with(\w*) a newline at the end$/ do |file_name, no_newline|
  file_contents = get_file_contents(file_name)
  expect(file_contents).to_not be_nil

  if no_newline.empty?
    file_contents << "\n" unless file_contents[-1] == "\n"
  else
    file_contents[-1] = '' if file_contents[-1] == "\n"
  end

  write_file(file_name, file_contents)
end

Given /^my configuration file "([^"]*)" looks like:$/ do |file_name, string|
  write_file(file_name, string)
end
