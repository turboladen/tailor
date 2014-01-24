require 'aruba/cucumber'
require 'simplecov'

SimpleCov.start do
  add_group 'Features', 'features/'
  add_group 'Lib', 'lib'
end
