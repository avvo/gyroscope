# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gyroscope/version'

Gem::Specification.new do |spec|
  spec.name          = "gyroscope"
  spec.version       = Gyroscope::VERSION
  spec.authors       = ["Chris Wilhelm", "Donald Plummer"]
  spec.email         = ["cwilhelm@avvo.com", "dplummer@avvo.com"]

  spec.summary       = %q{Build ActiveRecord search scopes from params hash}
  spec.description   = %q{Coerces values in params hash for search scoping}
  spec.homepage      = "https://github.com/avvo/gyroscope"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel"
  spec.add_dependency "activerecord"
  spec.add_dependency "activesupport"
  spec.add_dependency "virtus"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
