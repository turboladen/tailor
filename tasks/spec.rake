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

  desc "Run functional tests"
  RSpec::Core::RakeTask.new(:functional) do |t|
    t.pattern = "./spec/functional/**/*_spec.rb"
  end
end

