# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'auto/session/timeout/version'

Gem::Specification.new do |spec|
  spec.name          = "auto-session-timeout"
  spec.version       = Auto::Session::Timeout::VERSION
  spec.authors       = ["Matthew Bass"]
  spec.email         = ["pelargir@gmail.com"]
  spec.description   = %q{Automatic session timeout in Rails}
  spec.summary       = %q{Provides automatic session timeout in a Rails application.}
  spec.homepage      = "http://github.com/pelargir/auto-session-timeout"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "actionpack", [">= 3.2", "< 7.2"]
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", [">= 4.2", "< 6"]
end
