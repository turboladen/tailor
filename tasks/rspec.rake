require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = %w(-w)
  spec.rspec_opts = %w(--color)
end
task :test => :spec
