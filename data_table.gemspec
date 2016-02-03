Gem::Specification.new do |spec|
  spec.name              = 'data_table'
  spec.version           = '0.0.1'
  spec.date              = '2013-02-25'
  spec.summary     = "Manage sets of data and export."
  spec.description = "See README for full details on how to install, use, etc."
  spec.authors  = ["Michael Noack"]
  spec.email    = 'support@travellink.com.au'
  spec.homepage = 'http://github.com/sealink/data_table'

  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'coveralls'
end
