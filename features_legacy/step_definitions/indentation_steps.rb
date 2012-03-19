Given /^I have a file that looks like:\-$/ do |string|
  results = Tailor.find_problems_in source_string: string
end
