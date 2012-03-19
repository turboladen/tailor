require 'fakefs/spec_helpers'
require 'simplecov'

SimpleCov.start

$:.unshift(File.dirname(__FILE__) + '/../lib')

RSpec.configure do |conf|
  conf.include FakeFS::SpecHelpers
end

