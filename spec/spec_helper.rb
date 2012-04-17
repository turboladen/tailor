require 'fakefs/spec_helpers'
require 'simplecov'

SimpleCov.start

RSpec.configure do |conf|
  conf.include FakeFS::SpecHelpers
end
