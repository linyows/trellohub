# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trellohub/version'

Gem::Specification.new do |spec|
  spec.name          = 'trellohub'
  spec.version       = Trellohub::VERSION
  spec.authors       = ['linyows']
  spec.email         = ['linyows@gmail.com']
  spec.summary       = %q{Trellohub is uniform task management by synchronizing the github issues and trello cards.}
  spec.description   = %q{Trellohub is uniform task management by synchronizing the github issues and trello cards.}
  spec.homepage      = 'https://github.com/linyows/trellohub'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'octokit'
  spec.add_dependency 'trell'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
end
