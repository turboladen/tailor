require_relative 'lib/tailor'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

# Load rakefile extensions
Dir["tasks/*.rake"].each { |ext| load ext }

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name                 = 'tailor'
  gem.version              = Tailor::VERSION
  gem.summary              = "Utility for checking style of Ruby files."
  gem.authors              = ['Steve Loveless']
  gem.email                = ['steve.loveless@gmail.com']
  gem.post_install_message = File.readlines 'PostInstall.txt'
  gem.homepage             = 'http://github.com/turboladen/tailor'
  gem.description          = %Q{ruby style checking tool}
  gem.executables          = ['tailor']
  gem.extra_rdoc_files     = ['README.rdoc', 'ChangeLog.rdoc']
  gem.add_runtime_dependency 'term-ansicolor', '>=1.0.5'
  gem.add_development_dependency 'bundler', '~>1.0.12'
  gem.add_development_dependency 'code_statistics', '~>0.2.13'
  gem.add_development_dependency 'cucumber', '~>0.10.2'
  gem.add_development_dependency 'jeweler', '~>1.5.2'
  gem.add_development_dependency 'metric_fu', '>=2.0.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard', '~>0.6.8'
  gem.test_files = Dir.glob 'spec/**/*.rb'
end
Jeweler::RubygemsDotOrgTasks.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new(:features)

require 'yard'
YARD::Rake::YardocTask.new
