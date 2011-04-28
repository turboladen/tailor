$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'tailor'
require 'rspec'

def create_file_line(string, line_number)
  FileLine.new(string, Pathname.new(__FILE__), line_number)
end
