require 'bundler/gem_tasks'

# Load rakefile extensions
Dir["tasks/*.rake"].each { |ext| load ext }

desc "Run RSpec code examples"
task test: [:spec, :features]
task default: [:test]
