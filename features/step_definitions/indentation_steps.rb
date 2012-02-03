Given /^(.+) exists$/ do |file_name|
  path_chunks = file_name.split('/')
  const_name = path_chunks.first(2).each { |c| c.upcase! }.join("_")

  const = Kernel.const_get(const_name)
  file_contents = const[path_chunks.last.to_sym]
  file_contents.should_not be_nil

  write_file(file_name, file_contents)
end
