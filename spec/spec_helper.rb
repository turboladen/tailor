begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'tailor'

def create_file_line(string, line_number)
  FileLine.new(string, Pathname.new(__FILE__), line_number)
end
