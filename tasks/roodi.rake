require 'rake/tasklib'  # roodi_task fails without this.
require 'roodi'
require 'roodi_task'

RoodiTask.new do |t|
  t.config = 'tasks/roodi_config.yaml'
  t.patterns = Dir.glob("{features,lib,spec}/**/*.rb")
  t.verbose = true
end
