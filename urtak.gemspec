# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "urtak/version"

Gem::Specification.new do |s|
  s.name        = "urtak"
  s.version     = Urtak::VERSION
  s.authors     = ["Kunal Shah"]
  s.email       = ["kunal@urtak.com"]
  s.homepage    = "https://github.com/urtak/urtak-rb"
  s.summary     = %q{Ruby Client for the Urtak REST API}
  s.description = %q{Ruby Client for the Urtak REST API}

  s.rubyforge_project = "urtak"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeweb"
  s.add_development_dependency "vcr"
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "json"
end
