# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polished/knockout/version'

Gem::Specification.new do |spec|
  spec.name          = "polished-knockout"
  spec.version       = Polished::Knockout::VERSION
  spec.authors       = ["Jared White"]
  spec.email         = ["jared@jaredwhite.com"]
  spec.description   = %q{An Opal wrapper for creating view models that use Knockout.js for dynamic HTML updates and event handling}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/polished-rb/knockout-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'opal', '~> 0.8'
  spec.add_dependency 'opal-jquery', '~> 0.4'
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'opal-rspec', '~> 0.4'
end
