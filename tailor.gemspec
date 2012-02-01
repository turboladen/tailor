# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "tailor/version"

Gem::Specification.new do |s|
  s.name = "tailor"
  s.version = Tailor::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Steve Loveless"]
  s.date = "2011-09-26"
  s.description = "ruby style checking tool"
  s.email = ["steve.loveless@gmail.com"]
  s.executables = ["tailor"]
  s.extra_rdoc_files = [
    "ChangeLog.rdoc",
      "README.rdoc"
  ]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.extra_rdoc_files = %w(ChangeLog.rdoc README.rdoc)
  s.homepage = "http://github.com/turboladen/tailor"
  s.post_install_message = <<MSG
Thanks for checking out tailor.  To check Ruby style, simply do:
  $ tailor [directory to check]

  -OR-

  $ tailor [.rb/.erb file to check]

For more information on tailor, see http://github.com/turboladen/tailor)

MSG

  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Utility for checking style of Ruby files."
  s.test_files = Dir.glob "{feature,spec}/**/*_spec.rb"

  s.add_runtime_dependency(%q<log_switch>, [">= 0.2.0"])
  s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.0.5"])
  s.add_development_dependency(%q<code_statistics>, ["~> 0.2.13"])
  s.add_development_dependency(%q<cucumber>, [">= 0.10.2"])
  s.add_development_dependency(%q<metric_fu>, [">= 2.0.0"])
  s.add_development_dependency(%q<rspec>, [">= 2.5.0"])
  s.add_development_dependency(%q<simplecov>, [">= 0.4.0"])
  s.add_development_dependency(%q<yard>, [">= 0.6.8"])
end

