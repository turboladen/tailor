require 'yard'

YARD::Config.load_plugin 'cucumber'

YARD::Rake::YardocTask.new do |t|
  t.files = ['{features,lib}/**/*.{feature,rb}', "-", "History.rdoc"]
  t.options += %w(--readme README.rdoc)
  t.options += %w(--private --protected --verbose)
end
