# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'tailor/version'

Gem::Specification.new do |s|
  s.name = 'tailor'
  s.version = Tailor::VERSION

  s.author = 'Steve Loveless'
  s.summary = 'A Ruby style & complexity measurer'
  s.description = <<-DESC
tailor parses Ruby files and measures them with some style and static analysis
"rulers".  Default values for the Rulers are based on a number of style guides
in the Ruby community as well as what seems to be common.  More on this here
http://wiki.github.com/turboladen/tailor.

tailor's goal is to help you be consistent with your code, throughout your
project, whatever style that may be.
  DESC
  s.email = 'steve.loveless@gmail.com'
  s.homepage = 'http://github.com/turboladen/tailor'
  s.license = 'MIT'

  s.extra_rdoc_files = %w(History.md README.md)
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  s.add_runtime_dependency 'log_switch', '~> 0.3.0'
  s.add_runtime_dependency 'nokogiri', '>= 1.6.0'
  s.add_runtime_dependency 'term-ansicolor', '>= 1.0.5'
  s.add_runtime_dependency 'text-table', '>= 1.2.2'

  s.add_development_dependency 'aruba'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'cucumber', '>= 1.0.2'
  s.add_development_dependency 'fakefs', '>= 0.4.2'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.1'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'simplecov', '>= 0.4.0'
  s.add_development_dependency 'yard', '>= 0.7.0'
end
