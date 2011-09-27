$:.unshift File.dirname(__FILE__) + "/../../lib/tailor"
require "tailor"

gem 'cucumber'
require 'cucumber'
gem 'rspec'
require 'rspec'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path  = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  @features_path = File.dirname(__FILE__) + "/../"
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end
