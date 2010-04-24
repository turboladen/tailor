require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/tailor'

Hoe.plugin :newgem
Hoe.plugin :yard
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Gets the description from the main README file
def get_descr_from_readme
  paragraph_count = 0
  File.readlines('README.rdoc', '').each do |paragraph|
    paragraph_count += 1
    if paragraph_count == 4
      return paragraph
    end
  end
end

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'tailor' do
  self.summary      = "Utility for checking style of Ruby files."
  self.developer('Steve Loveless', 'steve.loveless@gmail.com')
  self.post_install_message = File.readlines 'PostInstall.txt'
  self.rubyforge_name = self.name
  self.version        = Tailor::VERSION
  self.url            = 'http://github.com/turboladen/tailor'
  self.description    = get_descr_from_readme
  self.readme_file    = 'README.rdoc'
  self.history_file   = 'History.txt'
  self.rspec_options  += ['--color', '--format', 'specdoc']
  self.extra_dev_deps += [
    ['rspec'],
    ['yard', '>=0.5.3'],
    ['hoe-yard', '>=0.1.2'],
    ['cucumber', '>=0.6.3']
  ]

  self.test_globs   = 'spec/*.rb'

  # Extra Yard options
  self.yard_title   = "#{self.name} Documentation (#{self.version})"
  self.yard_markup  = :rdoc
  self.yard_opts    += ['--main', self.readme_file]
  self.yard_opts    += ['--output-dir', 'doc']
  self.yard_opts    += ['--private']
  self.yard_opts    += ['--protected']
  self.yard_opts    += ['--verbose']
  self.yard_opts    += ['--files', 
    ['Manifest.txt', 'History.txt']
  ]
end

#-------------------------------------------------------------------------------
# Overwrite the :clobber_docs Rake task so that it doesn't destroy our docs
#   directory.
#-------------------------------------------------------------------------------
class Rake::Task
  def overwrite(&block)
    @actions.clear
    enhance(&block)
  end
end

Rake::Task[:clobber_docs].overwrite do
end

# Now define the tasks
require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# remove_task :default
# task :default => [:spec, :features]
