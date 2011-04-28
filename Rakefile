require 'rubygems'
require './lib/tailor'

# Load rakefile extensions
Dir["#{File.dirname(__FILE__)}/lib/tasks/*.rake"].each { |ext| load ext }

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name                 = 'tailor'
  gem.version              = Tailor::VERSION
  gem.summary              = "Utility for checking style of Ruby files."
  gem.authors              = ['Steve Loveless']
  gem.email                = ['steve.loveless@gmail.com']
  gem.post_install_message = File.readlines 'PostInstall.txt'
  gem.homepage             = 'http://github.com/turboladen/tailor'
  gem.description          = %Q{TODO}
  gem.executables          = ['tailor']
  gem.extra_rdoc_files     = ['README.rdoc', 'ChangeLog.rdoc']
  gem.add_runtime_dependency 'term-ansicolor', '>=1.0.5'
  gem.add_development_dependency 'cucumber', '~>0.10.2'
  gem.add_development_dependency 'jeweler', '~>1.5.2'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'yard', '~>0.6.8'
  gem.test_files = Dir.glob 'spec/**/*.rb'
end
Jeweler::RubygemsDotOrgTasks.new
