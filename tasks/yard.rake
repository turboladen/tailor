require 'yard'

YARD::Config.load_plugin 'cucumber'

YARD::Rake::YardocTask.new do |t|
  t.files = %w(lib/**/*.rb features/**/*.feature - History.rdoc)
  t.options += %w(--private --protected --verbose)
end
