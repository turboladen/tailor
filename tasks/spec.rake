require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

namespace :spec do
  desc "Run specs with Ruby warnings turned on"
  RSpec::Core::RakeTask.new(:warn) do |t|
    t.ruby_opts = %w(-w)
  end

  desc "Run specs for Tailor::Ruler"
  RSpec::Core::RakeTask.new(:lexer) do |t|
    t.pattern = "./spec/tailor/ruler_spec.rb"
  end
end

