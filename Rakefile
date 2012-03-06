require 'bundler/gem_tasks'

# Load rakefile extensions
Dir["tasks/*.rake"].each { |ext| load ext }

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

desc "Run RSpec code examples"
task :test => :spec
