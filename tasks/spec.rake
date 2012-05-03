require 'rspec/core/rake_task'

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

  desc "Run integration tests"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "./spec/integration/**/*_spec.rb"
  end
end

