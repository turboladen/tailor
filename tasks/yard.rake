require 'yard'

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
