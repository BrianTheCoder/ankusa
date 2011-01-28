# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ankusa/version"

Gem::Specification.new do |s|
  s.name        = "ankusa"
  s.version     = Ankusa::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["brianthecoder"]
  s.email       = ["brianthecoder@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{classifier with multiple backends}
  s.description = %q{classifier with multiple backends}

  s.rubyforge_project = "ankusa"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
