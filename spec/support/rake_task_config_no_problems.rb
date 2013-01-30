Tailor.config do |config|
  config.file_set 'spec/support/bad_indentation_cases.rb', :test do |style|
    style.max_line_length 1000, level: :error
  end
end
