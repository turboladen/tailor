require 'simplecov'

SimpleCov.start

=begin
def create_file_line(string, line_number)
  FileLine.new(string, Pathname.new(__FILE__), line_number)
end
=end

$:.unshift(File.dirname(__FILE__) + '/../lib')
