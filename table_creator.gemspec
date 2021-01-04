# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'table_creator/version'

Gem::Specification.new do |spec|
  spec.name              = 'table_creator'
  spec.version           = TableCreator::VERSION
  spec.date              = '2013-02-25'
  spec.summary     = "Manage sets of data and export."
  spec.description = "See README for full details on how to install, use, etc."
  spec.authors  = ["Michael Noack"]
  spec.email    = 'support@travellink.com.au'
  spec.homepage = 'http://github.com/sealink/table_creator'

  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'actionpack' # TagHelpers
  spec.add_dependency 'activesupport' # Hash#except, blank?, etc.

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'coverage-kit'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'pry'
end
