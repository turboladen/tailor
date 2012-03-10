# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tailor/version"

Gem::Specification.new do |s|
  s.name = "tailor"
  s.version = Tailor::VERSION

  s.author = "Steve Loveless"
  s.summary = "ruby style checking tool"
  s.description = "Utility for checking style of Ruby files."
  s.email = "steve.loveless@gmail.com"
  s.homepage = "http://github.com/turboladen/tailor"

  s.extra_rdoc_files = %w(ChangeLog.rdoc README.rdoc)
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.post_install_message = <<MSG
Thanks for checking out tailor.  To check Ruby style, simply do:
  $ tailor [directory to check]

  -OR-

  $ tailor [.rb/.erb file to check]

For more information on tailor, see http://github.com/turboladen/tailor)

MSG

  s.add_runtime_dependency(%q<log_switch>, ">= 0.2.0")
  s.add_runtime_dependency(%q<term-ansicolor>, ">= 1.0.5")
  s.add_runtime_dependency(%q<text-table>, ">= 1.2.2")
  s.add_runtime_dependency(%q<trollop>, ">= 1.16.2")

  s.add_development_dependency(%q<aruba>, ">=0")
  s.add_development_dependency(%q<cucumber>, ">= 1.0.2")
  s.add_development_dependency(%q<fakefs>, ">= 0.4.0")
  s.add_development_dependency(%q<rspec>, ">= 2.5.0")
  s.add_development_dependency(%q<roodi>, ">= 2.1.0")
  s.add_development_dependency(%q<simplecov>, ">= 0.4.0")
  s.add_development_dependency(%q<yard>, ">= 0.7.0")
  s.add_development_dependency(%q<yard-cucumber>, ">= 2.1.7")
end

