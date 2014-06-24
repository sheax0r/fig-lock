# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fig/lock/version'

Gem::Specification.new do |spec|
  spec.name          = "fig-lock"
  spec.version       = Fig::Lock::VERSION
  spec.authors       = ["Michael Shea"]
  spec.email         = ["michael.shea@salesforce.com"]
  spec.summary       = %q{Generates fig.lock files from fig.yml files}
  spec.description   = %q{Generates fig.lock files from fig.yml files}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "slop"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
end
