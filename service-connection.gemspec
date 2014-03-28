# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service/connection/version'

Gem::Specification.new do |spec|
  spec.name          = "service-connection"
  spec.version       = Service::Connection::VERSION
  spec.authors       = ["Lorenzo Tello"]
  spec.email         = ["devteam@ideas4all.com"]
  spec.summary       = "Http transport layer for ideas4all service api calls"
  spec.description   = "Http transport layer for ideas4all service api calls"
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
end
