# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kitchen/provisioner/chef_zero_nodes_version'

Gem::Specification.new do |spec|
  spec.name          = 'kitchen-chefzero-nodes'
  spec.version       = Kitchen::Provisioner::CHEF_ZERO_NODES_VERSION
  spec.authors       = ['Andrei Skopenko']
  spec.email         = ['andrei@skopenko.net']
  spec.description   = 'Test Kitchen provisioner based on chef_zero that generates searchable nodes'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/scopenco/kitchen-chefzero-nodes'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'test-kitchen'
  spec.add_dependency 'chef-dk'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
