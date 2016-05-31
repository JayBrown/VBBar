# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'badger/version'

Gem::Specification.new do |spec|
	spec.name          = 'VBBar'
	spec.version       = VBBar::VERSION
	spec.authors       = ['JayBrown']
	spec.description   = %q{Access and search the Berlin and Brandenburg public transportation information from the OS X menu bar}
	spec.summary       = %q{BitBar plugin (shell script) to access and search the Berlin and Brandenburg public transportation information from the OS X menu bar}
	spec.homepage      = 'https://github.com/JayBrown/VBBar/'
	spec.license       = 'MIT'
	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_dependency 'CoreLocationCLI', '~> 2.0.0'
	spec.add_dependency 'jq', '~> 1.5'
	spec.add_dependency 'mapbox', '~> 0.3.1'
	spec.add_dependency 'mlr', '~> 1.5'
	spec.add_dependency 'node', '~> 6.2.0'
	spec.add_dependency 'npm', '~> 3.8.9'
	spec.add_dependency 'terminal-notifier', '~> 1.6.3'
	spec.add_dependency 'vbb-dep', '~> 0.3.1'
	spec.add_dependency 'vbb-stations', '~> 0.6.0'
end