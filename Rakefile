require 'bundler/gem_tasks'
require 'cucumber'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard'


#------------------------------------------------------------------------------
# spec
#------------------------------------------------------------------------------
RSpec::Core::RakeTask.new

namespace :spec do
  desc "Run specs with Ruby warnings turned on"
  RSpec::Core::RakeTask.new(:warn) do |t|
    t.ruby_opts = %w(-w)
  end

  desc "Run unit tests"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "./spec/unit/**/*_spec.rb"
  end

  desc "Run functional tests"
  RSpec::Core::RakeTask.new(:functional) do |t|
    t.pattern = "./spec/functional/**/*_spec.rb"
  end
end

#------------------------------------------------------------------------------
# features
#------------------------------------------------------------------------------
Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = %w(--format progress features --tags ~@wip)
end

#------------------------------------------------------------------------------
# yard
#------------------------------------------------------------------------------
YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb - History.rdoc)
  t.options = %w(--private --protected --verbose)
end

namespace :yard do
  YARD::Rake::YardocTask.new(:with_features) do |t|
    YARD::Config.load_plugin 'cucumber'

    t.files = %w(lib/**/*.rb features/**/*.feature - History.rdoc)
  end
end


desc "Run RSpec examples and Cucumber features"
task test: [:spec, :features]
task default: [:test]
