# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/generate/version'

Gem::Specification.new do |spec|
  spec.name          = 'grape-gen'
  spec.version       = Grape::Generate::VERSION
  spec.authors       = ['AMar4enko']
  spec.email         = ['amar4enko@gmail.com']
  spec.summary       = %q{Grape-powered rack application generator with batteries included}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'thor', '~> 0.19.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
